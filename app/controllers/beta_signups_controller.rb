class BetaSignupsController < ApplicationController
  # Allow public access to beta signups
  skip_before_action :authenticate_user!, only: [:create, :thank_you]
  
  # Admin-only access to index and show
  before_action :ensure_admin!, only: [:index, :show]
  
  def create
    @beta_signup = BetaSignup.new(beta_signup_params)
    
    if @beta_signup.save
      # Send notification email to admin (when SMTP is configured)
      # BetaSignupMailer.new_signup(@beta_signup).deliver_later rescue nil
      
      # Send confirmation email to user (when SMTP is configured)
      # BetaSignupMailer.confirmation(@beta_signup).deliver_later rescue nil
      
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
end
