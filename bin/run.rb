#!/usr/bin/env ruby

require_relative '../env'

if ARGV.first
	emails_to_output = ARGV.first.to_i
else
	emails_to_output = 1
end

raw_messages = GmailHandler.new(emails_to_output).query_gmail_api
file_parser = FileParser.new(raw_messages)
file_parser.create_odt_files

if $?.exitstatus == 0
  puts "hurray!"
else
  puts "oh no!"
end
