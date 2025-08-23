require 'net/http'
require 'json'

class LinkedinProfileExportService
  class << self
    def export_profile_data(user)
      connection = user.linkedin_connection
      
      unless connection&.valid_connection?
        return { success: false, error: "No valid LinkedIn connection found" }
      end
      
      # Check what we can update on LinkedIn (most profile fields are read-only)
      # LinkedIn API typically only allows updating headline and summary
      updates_made = []
      
      # Update headline (if app has mission statement or bio)
      if user.mission_statement.present?
        headline_result = update_headline(connection, user.mission_statement)
        updates_made << "Headline" if headline_result[:success]
      end
      
      # Note: LinkedIn doesn't allow programmatic updating of most profile fields
      # But we can provide a formatted summary for manual copy-paste
      formatted_profile = generate_formatted_profile(user)
      
      {
        success: true,
        updates_made: updates_made,
        formatted_profile: formatted_profile,
        message: updates_made.any? ? 
          "LinkedIn updated: #{updates_made.join(', ')}" : 
          "Generated formatted profile for manual LinkedIn update"
      }
    end
    
    def generate_formatted_profile(user)
      # Generate a professionally formatted profile that users can copy-paste to LinkedIn
      profile_sections = {}
      
      # Professional Headline
      if user.mission_statement.present?
        profile_sections[:headline] = user.mission_statement
      elsif user.bio.present?
        # Extract first sentence or key phrase from bio
        first_sentence = user.bio.split('.').first&.strip
        profile_sections[:headline] = first_sentence if first_sentence.present?
      end
      
      # About/Summary Section
      if user.bio.present?
        about_section = user.bio.dup
        
        # Add mission statement if different from headline
        if user.mission_statement.present? && user.mission_statement != profile_sections[:headline]
          about_section += "\n\n#{user.mission_statement}"
        end
        
        # Add skills section if available
        if user.skills.present? && user.skills.any?
          about_section += "\n\nCore Expertise: #{user.skills.take(10).join(' • ')}"
        end
        
        profile_sections[:about] = about_section
      end
      
      # Skills list (for LinkedIn Skills section)
      if user.skills.present? && user.skills.any?
        profile_sections[:skills] = user.skills
      end
      
      # Experience section template
      if user.bio.present? || user.skills.present?
        profile_sections[:experience_template] = generate_experience_template(user)
      end
      
      profile_sections
    end
    
    private
    
    def update_headline(connection, headline)
      # LinkedIn API v2 doesn't typically allow headline updates
      # This is a placeholder for if they add this capability
      Rails.logger.info "LinkedIn headline update requested: #{headline}"
      
      # For now, return success but note it's not actually updated
      {
        success: false,
        error: "LinkedIn API doesn't allow programmatic headline updates"
      }
    end
    
    def generate_experience_template(user)
      # Generate a template for work experience based on user's profile
      template = {}
      
      if user.skills.present?
        # Group skills by likely job functions
        technical_skills = user.skills.select { |skill| technical_skill?(skill) }
        business_skills = user.skills.select { |skill| business_skill?(skill) }
        
        if technical_skills.any?
          template[:technical_role] = {
            title: "Software Developer / IT Professional",
            description: "Technical expertise in: #{technical_skills.take(8).join(', ')}"
          }
        end
        
        if business_skills.any?
          template[:business_role] = {
            title: "Business Consultant / Analyst", 
            description: "Business capabilities: #{business_skills.take(8).join(', ')}"
          }
        end
      end
      
      template
    end
    
    def technical_skill?(skill)
      technical_keywords = [
        'JavaScript', 'TypeScript', 'React', 'Next.js', 'Node.js', 'Python', 'Ruby', 'Rails',
        'HTML', 'CSS', 'SQL', 'PostgreSQL', 'AWS', 'Docker', 'Git', 'API', 'Database',
        'PowerShell', 'C#', '.NET', 'Linux', 'Windows', 'Cloud', 'DevOps', 'Security'
      ]
      
      technical_keywords.any? { |keyword| skill.downcase.include?(keyword.downcase) }
    end
    
    def business_skill?(skill)
      business_keywords = [
        'Marketing', 'Sales', 'Management', 'Leadership', 'Consulting', 'Strategy',
        'Project Management', 'Business', 'Analytics', 'Communication', 'Training'
      ]
      
      business_keywords.any? { |keyword| skill.downcase.include?(keyword.downcase) }
    end
  end
end