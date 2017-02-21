require 'nokogiri'
require_relative './assignment'

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
