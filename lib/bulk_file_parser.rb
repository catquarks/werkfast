require 'nokogiri'

class BulkFileParser
  attr_reader :raw_emails, :num_of_files_saved, :files_saved

  def initialize(raw_emails)
    @raw_emails = raw_emails
    @num_of_files_saved = 0
    @files_saved = []
  end

  def create_odt_files
    raw_emails.each do |raw_email|
      a = Assignment.new(raw_email)
      @files_saved.push(a.filename)
      @num_of_files_saved += 1
    end
  end

  def summarize_files_saved
    puts "#{num_of_files_saved} files have been saved to #{SAVE_PATH}!"
    puts "Files saved: "
    files_saved.each do |f|
      puts "\t" + f + ".odt"
    end
  end
end

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
      " ": "-"
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
    @keywords = assignment_body.css('span').text
  end

  def parse_assignment_body
    # binding.pry
    # assignment_body.to_html
    # assignment_body.match(/Article Topic and Information: <\/b><\/font>\s<br \/>([\s\S]*)/)[1].gsub(/<script>[\s\S]*<\/script>/, "")
  end

  def extract_assignment(email)
    # parsed_assignment = parse_assignment_body

    # header = create_assignment_header
    # header.gsub!("<br \/>", "").gsub!("\r" ,"")

    return keywords
  end

end
