class TestMailer < ApplicationMailer
  def test_email(to_email)
    @timestamp = Time.current
    @app_name = "No iLLusion SMM"
    
    mail(
      to: to_email,
      subject: "Welcome to No iLLusion SMM - Your Account is Ready!"
    )
  end
  
  def beta_invitation(to_email, name = "Beta Tester")
    @name = name
    @timestamp = Time.current
    @app_name = "No iLLusion SMM"
    
    mail(
      to: to_email,
      subject: "🎉 You're Invited! No iLLusion SMM Beta Access"
    )
  end
end
