#!/usr/bin/env ruby

require_relative '../lib/cli'
require_relative '../lib/email_scrape'
require_relative '../lib/bulk_file_parser'
require_relative '../lib/gmail_handler'

require 'google/apis/gmail_v1'
require 'googleauth'
require 'googleauth/stores/file_token_store'
require 'fileutils'
require 'pry'

SavePath = Cli::SavePath

SAVE_PATH = SavePath.create_save_path
USER_ID = 'me'
SEARCH_PARAMS = Cli::SearchParams.create_search_params
OOB_URI = 'urn:ietf:wg:oauth:2.0:oob'
APPLICATION_NAME = 'Werkfast'
CLIENT_SECRETS_PATH = 'client_secret.json'
CREDENTIALS_PATH = File.join(Dir.home, '.credentials',
                             "gmail-ruby-quickstart.yaml")
SCOPE = Google::Apis::GmailV1::AUTH_GMAIL_READONLY

num_of_emails = Cli.number_of_arguments
raw_messages = GmailHandler.new.query_gmail_api(num_of_emails)
file_parser = BulkFileParser.new(raw_messages)
file_parser.create_odt_files
file_parser.summarize_files_saved

puts "all done!"
exit
