class ApplicationMailer < ActionMailer::Base
  default from: ENV['SMTP_FROM_EMAIL'] || 'noreply@no-illusion.com'
  layout "mailer"
end
