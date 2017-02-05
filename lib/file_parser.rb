require 'nokogiri'

class FileParser
  attr_reader :raw_emails

  def initialize(raw_emails)
    @raw_emails = raw_emails
  end

  def create_odt_files
    raw_emails.each do |raw_email|
      Assignment.new(raw_email)
    end
  end
end

class Assignment
  attr_reader :client_name, :due_date
  @@word_substitutions = {
    "&": "and",
    "%": "percent",
    "$": "dollar",
    "@": "at",
    "'": "",
    ".": "",
    ",": "",
    "(": "",
    ")": "",
    "?": "",
    "!": "",
    "#": "",
    "/": "-",
    "~": "",
    "`": "",
    ":": "-",
    " ": "-"
  }    

  def initialize(raw_email)
    subject = EmailScrape.get_email_subject(raw_email)
    @client_name = get_client_name_from_email_subject(subject)
    @due_date = get_due_date_from_email_subject(subject)

    filename = create_filename
    odt_file = File.open("#{VIVIAL_PATH}/#{filename}.odt", "w")
    assignment = extract_assignment(raw_email)
    odt_file << assignment
    odt_file.close
  end

  def get_client_name_from_email_subject(subject)
    subject.gsub(" Sent to:", "").split(/\d{1,2}\/\d{1,2}\/\d{4}\s/).last.downcase
  end

  def get_due_date_from_email_subject(subject)
    subject.match(/\d{1,2}\/\d{1,2}\/\d{4}/).to_s.gsub("/", "-")
  end

  def perform_character_substitutions(text)
    text = text.split("")

    text.map! do |char|
      if @@word_substitutions.keys.include?(char.to_sym)
        @@word_substitutions[char.to_sym]
      else
        char
      end
    end

    text.join("")
  end

  def check_for_existing_file_names(base_filename)
    filename = base_filename
    i = 2
    while File.exist?("#{VIVIAL_PATH}/#{filename}.odt")
      filename = base_filename + "_#{i}"
      i += 1
    end
    if i > 2
      puts "This client is popular! Writing to #{filename}.odt..."
    end
    yield filename
  end

  def create_filename
    parsed_client_name = perform_character_substitutions(client_name)
    base_filename = "#{client_name}_#{due_date}"
    check_for_existing_file_names(base_filename) do |filename|
      filename
    end
  end

  def get_assignment_keywords(assignment_body)
    "<p>" + assignment_body.match(/Keywords:[\s\S]*()<\/span>\s*<\/p>/)[0].gsub("Keywords: ", "")
  end

  def create_assignment_header(keywords, assignment_body)
    "<html><body>" + assignment_body.match(/.*/)[0] + keywords
  end

  def parse_assignment_body(raw_data)
    raw_data.match(/Article Topic and Information: <\/b><\/font>\s<br \/>([\s\S]*)/)[1].gsub(/<script>[\s\S]*<\/script>/, "")
  end

  def extract_assignment(email)
    assignment_body = EmailScrape.get_assignment_body(email)
    parsed_assignment_body = parse_assignment_body(assignment_body)
    keywords = get_assignment_keywords(assignment_body)
    assignment_body.gsub!(keywords, "")
    header = create_assignment_header(keywords, assignment_body)
    header.gsub!("<br \/>", "").gsub!("\r" ,"")

    return header + assignment_body
  end

end
