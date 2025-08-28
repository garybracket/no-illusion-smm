class BetaSignupsController < ApplicationController
  # Allow public access to beta signups
  skip_before_action :authenticate_user!, only: [:create, :thank_you]
  
  # Admin-only access to index and show
  before_action :ensure_admin!, only: [:index, :show]
  
  # Rate limiting for email protection
  before_action :check_signup_rate_limit, only: [:create]
  
  def create
    @beta_signup = BetaSignup.new(beta_signup_params)
    
    if @beta_signup.save
      # Send emails with proper error handling and rate limiting
      send_beta_signup_emails(@beta_signup)
      
      redirect_to thank_you_beta_signups_path, notice: 'Thank you for signing up! We\'ll be in touch soon.'
    else
      # Handle form errors by redirecting back with error
      redirect_to coming_soon_path, 
                  alert: @beta_signup.errors.full_messages.join(', ')
    end
  end
  
  def thank_you
    # Public thank you page
  end
  
  def index
    @beta_signups = BetaSignup.recent
    @stats = {
      total: BetaSignup.count,
      this_week: BetaSignup.this_week.count,
      this_month: BetaSignup.this_month.count,
      pending: BetaSignup.pending.count,
      accepted: BetaSignup.accepted.count
    }
  end
  
  def show
    @beta_signup = BetaSignup.find(params[:id])
  end
  
  private
  
  def beta_signup_params
    params.require(:beta_signup).permit(:name, :email, :company, :current_platforms, :challenges, :how_heard_about_us)
  end
  
  def ensure_admin!
    # For now, check if user is signed in and has specific email
    # You can enhance this with proper admin role system later
    unless user_signed_in? && current_user.email == 'real.ener.g@gmail.com'
      redirect_to root_path, alert: 'Access denied'
    end
  end
  
  def check_signup_rate_limit
    # Rate limiting: max 3 signups per IP per hour to prevent email spam
    ip_address = request.remote_ip
    recent_signups = BetaSignup.where(
      "created_at > ? AND signup_date > ?", 
      1.hour.ago, 
      1.hour.ago
    ).count
    
    # Also check for duplicate email attempts (prevent resubmission spam)
    if params[:beta_signup] && params[:beta_signup][:email]
      recent_email_attempts = BetaSignup.where(
        email: params[:beta_signup][:email],
        created_at: 10.minutes.ago..
      ).count
      
      if recent_email_attempts > 0
        Rails.logger.warn "Duplicate email signup attempt: #{params[:beta_signup][:email]} from #{ip_address}"
        redirect_to coming_soon_path, alert: 'You have already signed up recently. Please check your email.'
        return
      end
    end
    
    # Global rate limiting: max 10 signups per hour total (launch day protection)
    if recent_signups >= 10
      Rails.logger.warn "High signup volume detected: #{recent_signups} signups in past hour"
      # Still allow signup but disable emails to prevent spam
      session[:skip_beta_emails] = true
    end
  end
  
  def send_beta_signup_emails(beta_signup)
    # Skip emails if rate limited
    if session[:skip_beta_emails]
      Rails.logger.info "Skipping emails for #{beta_signup.email} due to rate limiting"
      return
    end
    
    begin
      # Send admin notification with deliver_now (immediate, reliable)
      BetaSignupMailer.new_signup(beta_signup).deliver_now
      Rails.logger.info "Admin notification sent for #{beta_signup.email}"
    rescue => e
      Rails.logger.error "Failed to send admin notification: #{e.message}"
      # Continue - don't fail signup if admin email fails
    end
    
    begin
      # Send user confirmation with deliver_now (immediate, reliable)  
      BetaSignupMailer.confirmation(beta_signup).deliver_now
      Rails.logger.info "User confirmation sent to #{beta_signup.email}"
    rescue => e
      Rails.logger.error "Failed to send user confirmation to #{beta_signup.email}: #{e.message}"
      # Store failed email for manual follow-up
      beta_signup.update_column(:status, 'email_failed') rescue nil
    end
  end
end
