class ResumeController < ApplicationController
  before_action :authenticate_user!
  
  def show
    # Display current resume data (for editing)
    @resume_data = build_resume_data
  end
  
  def edit
    # Form to edit resume fields
    @user = current_user
  end
  
  def update
    # Update resume fields
    if current_user.update(resume_params)
      redirect_to resume_path, notice: 'Resume updated successfully'
    else
      render :edit
    end
  end
  
  def import
    # Handle file upload for resume import
    if params[:resume_file].present?
      result = ResumeImportService.import_from_file(current_user, params[:resume_file])
      
      if result[:success]
        redirect_to resume_path, notice: "Resume imported! Fields updated: #{result[:imported_fields].join(', ')}"
      else
        redirect_to resume_path, alert: "Import failed: #{result[:error]}"
      end
    elsif params[:resume_text].present?
      # Handle copy-paste text import
      result = ResumeImportService.import_from_text(current_user, params[:resume_text])
      
      if result[:success]
        redirect_to resume_path, notice: 'Resume text imported successfully'
      else
        redirect_to resume_path, alert: "Import failed: #{result[:error]}"
      end
    else
      redirect_to resume_path, alert: 'Please provide a file or paste resume text'
    end
  end
  
  def preview
    # Generate and show HTML preview
    @html = ResumeGeneratorService.generate_html(current_user, template_params)
    
    respond_to do |format|
      format.html { render html: @html.html_safe }
      format.json { render json: { html: @html } }
    end
  end
  
  def download
    # Generate downloadable HTML/PDF
    result = ResumeGeneratorService.generate_pdf(current_user, template_params)
    
    # For now, send HTML with print styles
    # Later can use wicked_pdf or similar for true PDF
    html_content = <<~HTML
      #{result[:html]}
      <style>#{result[:css]}</style>
      <script>window.print();</script>
    HTML
    
    send_data html_content, 
              filename: result[:filename].gsub('.pdf', '.html'),
              type: 'text/html',
              disposition: 'attachment'
  end
  
  def sync_from_linkedin
    # Import LinkedIn data to resume fields
    result = LinkedinProfileImportService.import_profile_data(current_user)
    
    if result[:success]
      # Map LinkedIn data to resume fields
      map_linkedin_to_resume(current_user)
      redirect_to resume_path, notice: 'LinkedIn data synced to resume'
    else
      redirect_to resume_path, alert: "LinkedIn sync failed: #{result[:error]}"
    end
  end
  
  private
  
  def resume_params
    params.require(:user).permit(
      :professional_summary,
      :phone,
      :location,
      :linkedin_url,
      :github_url,
      :portfolio_url,
      :resume_template,
      :resume_color_scheme,
      certifications: [],
      work_experience: [:company, :position, :location, :start_date, :end_date, responsibilities: [], technologies: []],
      education: [:school, :degree, :field, :graduation_date, :gpa, achievements: []]
    )
  end
  
  def template_params
    params.permit(:template, :color_scheme)
  end
  
  def build_resume_data
    {
      contact: {
        name: current_user.name,
        email: current_user.email,
        phone: current_user.phone,
        location: current_user.location,
        linkedin_url: current_user.linkedin_url,
        github_url: current_user.github_url,
        portfolio_url: current_user.portfolio_url
      },
      summary: current_user.professional_summary || current_user.bio,
      experience: current_user.work_experience || [],
      education: current_user.education || [],
      skills: current_user.skills || [],
      certifications: current_user.certifications || []
    }
  end
  
  def map_linkedin_to_resume(user)
    # If LinkedIn bio is better, use it for professional summary
    if user.bio.present? && user.professional_summary.blank?
      user.professional_summary = user.bio
    end
    
    # LinkedIn URL should be set if connected
    if user.linkedin_connected? && user.linkedin_url.blank?
      # Try to construct LinkedIn URL (would need actual profile URL from API)
      user.linkedin_url = "https://www.linkedin.com/in/#{user.name.parameterize}"
    end
    
    user.save
  end
end