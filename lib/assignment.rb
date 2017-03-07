require 'nokogiri'

class Assignment
  attr_reader :client_name, :due_date, :assignment_body, :keywords, :word_substitutions, :filename

  def initialize(raw_email)
    @word_substitutions = {
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
      " ": "-",
      "\\", " ",
      "|", "-"
    }
    subject = EmailScrape.get_email_subject(raw_email)
    @client_name = get_client_name_from_email_subject(subject)
    @due_date = get_due_date_from_email_subject(subject)
    raw_assignment_body = EmailScrape.get_email_body(raw_email)
    @assignment_body = Nokogiri::HTML(raw_assignment_body)
    get_assignment_keywords

    @filename = create_filename
    odt_file = File.open("#{SAVE_PATH}/#{@filename}.odt", "w")
    assignment = extract_assignment(raw_email)
    odt_file << assignment
    odt_file.close
  end

  def get_client_name_from_email_subject(subject)
    subject.gsub(" Sent to:", "")
      .split(/\d{1,2}\/\d{1,2}\/\d{4}\s/).last.downcase
  end

  def get_due_date_from_email_subject(subject)
    subject.match(/\d{1,2}\/\d{1,2}\/\d{4}/).to_s.gsub("/", "-")
  end

  def perform_character_substitutions(text)
    text = text.split("")

    text.map! do |char|
      if @word_substitutions.keys.include?(char.to_sym)
        @word_substitutions[char.to_sym]
      else
        char
      end
    end

    text.join("")
  end

  def check_for_existing_file_names(base_filename)
    filename = base_filename
    i = 2
    while File.exist?("#{SAVE_PATH}/#{filename}.odt")
      filename = base_filename + "_#{i}"
      i += 1
    end

    yield filename
  end

  def create_filename
    parsed_client_name = perform_character_substitutions(client_name)
    base_filename = "#{parsed_client_name}_#{due_date}"
    check_for_existing_file_names(base_filename) do |filename|
      filename
    end
  end

  def get_assignment_keywords
    @keywords = assignment_body.css('span').to_html
  end

  def parse_assignment_topic
    topic = assignment_body.css('p')[3..4]
    topic.css('b')[0].remove
    topic.css('br')[0].remove
    topic.to_html
  end

  def parse_assignment_body
    assignment_body.css('p')[5, 9].to_html
  end

  def extract_assignment(email)
    body = parse_assignment_body
    topic = parse_assignment_topic
    return topic + keywords + body
  end

end
