class PagesController < ApplicationController
  # Allow public access to legal pages for LinkedIn app review
  skip_before_action :authenticate_user!, only: [:privacy, :terms]
  
  def privacy
    # Privacy policy page - public access required for LinkedIn app review
  end
  
  def terms
    # Terms of service page - public access required for LinkedIn app review
  end
end