class FileParser
  attr_reader :raw_messages
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
    ":": "_"
  }

  def initialize(raw_messages)
    @raw_messages = raw_messages
  end

  def create_odt_files
    raw_messages.each do |message|
      filename = create_filename(message)
      odt_file = File.open("#{VIVIAL_PATH}/#{filename}.odt", "w")
      assignment = extract_assignment(message)
      odt_file << assignment
      odt_file.close
    end
  end

  def get_email_subject(email)
    email.payload.headers.find {|header| header.name == "Subject"}.value
  end

  def get_client_name_from_email_subject(subject)
    client_name = subject.split(/\d{1,2}\/\d{1,2}\/\d{4}\s/).last.gsub(" ", "_").downcase
  end

  def perform_character_substitutions(text)
    @@word_substitutions.each do |char, text|
      if text.include?(char.to_s)
        text.gsub!(char.to_s, text)
      end
    end
    text
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

  def create_filename(email)
    subject = get_email_subject(email)
    client_name = get_client_name_from_email_subject(subject)
    parsed_client_name = perform_character_substitutions(client_name)
    due_date = subject.match(/\d{1,2}\/\d{1,2}\/\d{4}/).to_s.gsub("/", "-")
    base_filename = "#{client_name}_#{due_date}"

    check_for_existing_file_names(base_filename) do |filename|
      filename
    end
  end

  def get_assignment_body(email)
    email.payload.parts[1].body.data.match(/Article Topic and Information: <\/b><\/font>\s<br \/>([\s\S]*)/)[1].gsub(/<script>[\s\S]*<\/script>/, "")
  end

  def get_assignment_keywords(assignment_body)
    "<p>" + assignment_body.match(/Keywords:[\s\S]*()<\/span>\s*<\/p>/)[0].gsub("Keywords: ", "")
  end

  def create_assignment_header(keywords, assignment_body)
    "<html><body>" + assignment_body.match(/.*/)[0] + keywords
  end

  def extract_assignment(email)
    assignment_body = get_assignment_body(email)
    keywords = get_assignment_keywords(assignment_body)
    assignment_body.gsub!(keywords, "")
    header = create_assignment_header(keywords, assignment_body)
    header.gsub!("<br \/>", "").gsub!("\r" ,"")

    return header + assignment_body
  end

end