#!/usr/bin/env ruby

require_relative '../env'
require_relative '../lib/cli_helper'
require_relative '../lib/email_scrape'
require_relative '../lib/file_parser'

num_of_args = CliHelper.number_of_arguments

raw_messages = GmailHandler.new.query_gmail_api(num_of_args)
file_parser = FileParser.new(raw_messages)
file_parser.create_odt_files

CliHelper.determine_exit_status
