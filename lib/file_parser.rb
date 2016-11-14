class FileParser
  attr_reader :raw_messages

  def initialize(raw_messages)
    @raw_messages = raw_messages
  end

  def create_odt_files
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
    # need to fix so doesnt cut off multi-line topics
    keywords = "<p>" + assignment_body.match(/Keywords:[\s\S]*()<\/span>\s*<\/p>/)[0].gsub("Keywords: ", "")
    assignment_body.gsub!(keywords, "")
    header = "<html><body>" + assignment_body.match(/.*/)[0] + keywords
    header.gsub!("<br \/>", "").gsub!("\r" ,"")
    return header + assignment_body
  end

end