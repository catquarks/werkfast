class GmailHandler

  attr_accessor :emails_to_query, :user_id

  def initialize(emails_to_query=1)
    @emails_to_query = emails_to_query
    @user_id = USER_ID
  end

  def authorize
    FileUtils.mkdir_p(File.dirname(CREDENTIALS_PATH))
    client_id = Google::Auth::ClientId.from_file(CLIENT_SECRETS_PATH)
    token_store = Google::Auth::Stores::FileTokenStore.new(file: CREDENTIALS_PATH)
    authorizer = Google::Auth::UserAuthorizer.new(
      client_id, SCOPE, token_store)
    user_id = 'default'
    credentials = authorizer.get_credentials(user_id)
    if credentials.nil?
      url = authorizer.get_authorization_url(
        base_url: OOB_URI)
      puts "Open the following URL in the browser and enter the " +
           "resulting code after authorization"
      puts url
      code = gets
      credentials = authorizer.get_and_store_credentials_from_code(
        user_id: user_id, code: code, base_url: OOB_URI)
    end
    credentials
  end

  def query_gmail_api(emails_to_query)
    service = Google::Apis::GmailV1::GmailService.new
    service.client_options.application_name = APPLICATION_NAME
    service.authorization = authorize
    initial_query = service.list_user_messages(user_id, include_spam_trash: nil, label_ids: nil, max_results: 50, q: SEARCH_PARAMS).messages
    if initial_query == nil
      abort "No emails found!"
    end
    email_ids = initial_query.map {|email| email.id}
    chronological_messages = email_ids.map {|id| service.get_user_message(user_id, id)}.reverse.take(emails_to_query)
    return chronological_messages
  end

end