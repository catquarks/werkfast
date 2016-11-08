require 'google/apis/gmail_v1'
require 'googleauth'
require 'googleauth/stores/file_token_store'
require 'fileutils'
require 'pry'

VIVIAL_PATH = "/home/tami/Dropbox/LocalVox"
OOB_URI = 'urn:ietf:wg:oauth:2.0:oob'
APPLICATION_NAME = 'Gmail API Ruby Quickstart'
CLIENT_SECRETS_PATH = 'client_secret.json'
CREDENTIALS_PATH = File.join(Dir.home, '.credentials',
                             "gmail-ruby-quickstart.yaml")
SCOPE = Google::Apis::GmailV1::AUTH_GMAIL_READONLY

def authorize
  FileUtils.mkdir_p(File.dirname(CREDENTIALS_PATH))
  client_id = Google::Auth::ClientId.from_file(CLIENT_SECRETS_PATH)
  token_store = Google::Auth::Stores::FileTokenStore.new(file: CREDENTIALS_PATH)
  authorizer = Google::Auth::UserAuthorizer.new(
    client_id, SCOPE, token_store)
  user_id = 'default'
  credentials = authorizer.get_credentials(user_id)
  if credentials.nil?
    url = authorizer.get_authorization_url(
      base_url: OOB_URI)
    puts "Open the following URL in the browser and enter the " +
         "resulting code after authorization"
    puts url
    code = gets
    credentials = authorizer.get_and_store_credentials_from_code(
      user_id: user_id, code: code, base_url: OOB_URI)
  end
  credentials
end

def query_gmail_api(emails_to_output=1)
  service = Google::Apis::GmailV1::GmailService.new
  service.client_options.application_name = APPLICATION_NAME
  service.authorization = authorize
  user_id = 'me'
  initial_query = service.list_user_messages(user_id, include_spam_trash: nil, label_ids: nil, max_results: emails_to_output, q: "from:localvox.com is:unread").messages
  email_ids = initial_query.map {|email| email.id}
  raw_messages = email_ids.map {|id| service.get_user_message(user_id, id)}
  return create_odt_files(raw_messages)
end

def create_odt_files(raw_messages)
  raw_messages.each do |message|
    filename = create_filename(message)
    output = File.open("#{VIVIAL_PATH}/#{filename}.odt", "w")
    assignment = extract_assignment(message)
    output << assignment
    output.close
  end

end

def create_filename(email)
  subject = email.payload.headers.find {|header| header.name == "Subject"}.value
  client_name = subject.split(/\d{1,2}\/\d{1,2}\/\d{4}\s/).last.gsub(" ", "_").downcase
  subs = {"&": "and", "%": "percent", "$": "dollar", "@": "at", "'": "", ".": "", ",": "", "(": "", ")": "", "?": "", "!": "", "#": "", "/": "", "~": "", "`": ""}
  subs.each do |char, text|
    if client_name.include?(char.to_s)
      client_name.gsub!(char.to_s, text)
    end
  end

  due_date = subject.match(/\d{1,2}\/\d{1,2}\/\d{4}/).to_s.gsub("/", "-")
  base_filename = "#{client_name}_#{due_date}"

  filename = base_filename
  i = 2
  while File.exist?("#{VIVIAL_PATH}/#{filename}.odt")
    filename = base_filename + "_#{i}"
    i += 1
  end
  if i > 2
    puts "This client is popular! Writing to #{filename}.odt..."
  end
  return filename
end

def extract_assignment(email)
  assignment_body = email.payload.parts[1].body.data.match(/Article Topic and Information: <\/b><\/font>\s<br \/>([\s\S]*)/)[1].gsub(/<script>[\s\S]*<\/script>/, "")
  keywords = "<p>" + assignment_body.match(/Keywords:[\s\S]*()<\/span>\s*<\/p>/)[0].gsub("Keywords: ", "")
  assignment_body.gsub!(keywords, "")
  header = "<html><body>" + assignment_body.match(/.*/)[0] + keywords
  header.gsub!("<br \/>", "").gsub!("\r" ,"")
  return header + assignment_body
end

emails_to_output = 1
emails_to_output = ARGV.first.to_i if ARGV.first
query_gmail_api(emails_to_output)

if $?.exitstatus == 0
  puts "hurray!"
else
  puts "oh no!"
end