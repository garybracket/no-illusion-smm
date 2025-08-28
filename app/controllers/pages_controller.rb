class PagesController < ApplicationController
  # Allow public access to legal pages and pricing for LinkedIn app review
  skip_before_action :authenticate_user!, only: [:privacy, :terms, :pricing]
  
  def privacy
    # Privacy policy page - public access required for LinkedIn app review
  end
  
  def terms
    # Terms of service page - public access required for LinkedIn app review
  end
  
  def pricing
    # Professional pricing page showcasing tier features
  end
end