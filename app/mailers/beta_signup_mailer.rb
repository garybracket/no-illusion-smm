class BetaSignupMailer < ApplicationMailer
  default from: ENV['SMTP_FROM_EMAIL'] || 'noreply@no-illusion.com'

  def new_signup(beta_signup)
    @beta_signup = beta_signup
    @admin_email = ENV['ADMIN_NOTIFICATION_EMAIL'] || ENV['ADMIN_EMAIL'] || 'real.ener.g@gmail.com'

    mail(
      to: @admin_email,
      subject: "New Beta Signup: #{@beta_signup.name}"
    )
  end

  def confirmation(beta_signup)
    @beta_signup = beta_signup

    mail(
      to: @beta_signup.email,
      subject: "Welcome to No iLLusion SMM Beta Program!"
    )
  end
end
