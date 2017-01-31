#!/usr/bin/env ruby

require_relative '../env'

raw_messages = GmailHandler.new(CliHelper.number_of_arguments).query_gmail_api
file_parser = FileParser.new(raw_messages)
file_parser.create_odt_files

CliHelper.determine_exit_status
