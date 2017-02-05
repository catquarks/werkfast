module EmailScrape

  def EmailScrape.get_email_subject(email)
    email.payload.headers.find {|header| header.name == "Subject"}.value
  end

  def EmailScrape.get_assignment_body(email)
    email.payload.parts[1].body.data
  end

end
