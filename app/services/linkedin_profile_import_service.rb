require 'net/http'
require 'json'

class LinkedinProfileImportService
  LINKEDIN_API_BASE = 'https://api.linkedin.com/v2'
  
  class << self
    def import_profile_data(user)
      connection = user.linkedin_connection
      
      unless connection&.valid_connection?
        return { success: false, error: "No valid LinkedIn connection found" }
      end
      
      # Get basic profile information
      profile_result = get_profile(connection)
      return profile_result unless profile_result[:success]
      
      # Get skills (if available)
      skills_result = get_skills(connection)
      
      # Map and update user profile
      update_result = map_and_update_profile(user, profile_result[:profile], skills_result[:skills])
      
      if update_result[:success]
        Rails.logger.info "LinkedIn profile imported for user #{user.id}: #{profile_result[:profile][:name]}"
        {
          success: true,
          message: "Profile imported successfully from LinkedIn",
          imported_data: update_result[:imported_data]
        }
      else
        {
          success: false,
          error: update_result[:error]
        }
      end
    end
    
    def get_profile(connection)
      # Get detailed profile information using the public API method
      result = LinkedinApiService.get_profile(connection)
      
      if result[:success]
        profile_data = result[:profile]
        
        {
          success: true,
          profile: {
            id: profile_data['id'],
            first_name: profile_data['firstName'],
            last_name: profile_data['lastName'], 
            name: profile_data['name'],
            email: profile_data['email'],
            picture_url: profile_data['picture']
          }
        }
      else
        {
          success: false,
          error: "Failed to fetch LinkedIn profile: #{result[:error]}"
        }
      end
    end
    
    def get_skills(connection)
      # LinkedIn Skills API (may require additional permissions) - using public API method
      result = LinkedinApiService.get_skills(connection)
      
      if result[:success]
        skills_data = result[:skills]
        skills = skills_data.dig('elements')&.map do |skill|
          skill.dig('skill', 'name', 'localized', 'en_US') || skill.dig('skill', 'name')
        end&.compact || []
        
        { success: true, skills: skills }
      else
        # Skills API might not be available, return empty but successful
        Rails.logger.warn "LinkedIn skills fetch failed (this is often expected): #{result[:error]}"
        { success: true, skills: [] }
      end
    end
    
    private
    
    def map_and_update_profile(user, linkedin_profile, linkedin_skills)
      imported_data = {}
      
      begin
        # Build full name (LinkedIn /userinfo provides 'name' directly)
        full_name = linkedin_profile[:name] || [linkedin_profile[:firstName], linkedin_profile[:lastName]].compact.join(' ')
        if full_name.present? && full_name != user.name
          user.name = full_name
          imported_data[:name] = full_name
        end
        
        # Update email if provided and different
        if linkedin_profile[:email].present? && linkedin_profile[:email] != user.email
          # Note: We typically don't update email as it's used for auth, but store it in settings
          imported_data[:linkedin_email] = linkedin_profile[:email]
        end
        
        # Since LinkedIn /userinfo doesn't provide headline/summary, we'll need to be creative
        # We can use the name to create a professional presence indicator
        if user.bio.blank?
          # Only set a basic bio if user doesn't have one
          user.bio = "Professional on LinkedIn"
          imported_data[:bio] = user.bio
        end
        
        # LinkedIn /userinfo doesn't provide detailed profile data
        # We'll merge LinkedIn skills if available (from get_skills API call)
        if linkedin_skills.any?
          current_skills = user.skills || []
          new_skills = (current_skills + linkedin_skills).uniq.sort
          
          if new_skills != current_skills
            user.skills = new_skills
            imported_data[:skills] = new_skills
          end
        end
        
        # Since LinkedIn /userinfo doesn't provide detailed profile info,
        # we'll skip automatic mission statement generation for now
        
        if user.save
          {
            success: true,
            imported_data: imported_data
          }
        else
          {
            success: false,
            error: "Failed to save user profile: #{user.errors.full_messages.join(', ')}"
          }
        end
        
      rescue => e
        Rails.logger.error "LinkedIn profile mapping error: #{e.message}"
        {
          success: false,
          error: "Profile mapping failed: #{e.message}"
        }
      end
    end
    
    def extract_skills_from_profile(profile, linkedin_skills)
      skills = []
      
      # Add LinkedIn skills if available
      skills.concat(linkedin_skills) if linkedin_skills.present?
      
      # Extract skills from positions (job titles and descriptions)
      profile[:positions].each do |position|
        title = position.dig('title', 'localized', 'en_US') || position['title']
        summary = position.dig('summary', 'localized', 'en_US') || position['summary']
        
        # Map common job titles to skills
        skills.concat(extract_skills_from_text(title)) if title.present?
        skills.concat(extract_skills_from_text(summary)) if summary.present?
      end
      
      # Extract from headline and summary
      [profile[:headline], profile[:summary]].each do |text|
        skills.concat(extract_skills_from_text(text)) if text.present?
      end
      
      # Clean and deduplicate
      skills.map(&:strip).uniq.reject(&:blank?).take(20) # Limit to 20 skills
    end
    
    def extract_skills_from_text(text)
      return [] unless text.present?
      
      # Common technical and business skills to look for
      skill_keywords = [
        # Technical
        'JavaScript', 'TypeScript', 'React', 'Next.js', 'Node.js', 'Python', 'Ruby', 'Rails',
        'HTML', 'CSS', 'Tailwind', 'SQL', 'PostgreSQL', 'AWS', 'Docker', 'Git',
        # Business & Marketing
        'Marketing', 'Social Media', 'Content Creation', 'SEO', 'Analytics', 'Strategy',
        'Project Management', 'Leadership', 'Sales', 'Business Development', 'Consulting',
        'Graphic Design', 'UI/UX', 'Copywriting', 'Email Marketing', 'Digital Marketing'
      ]
      
      found_skills = []
      skill_keywords.each do |skill|
        found_skills << skill if text.downcase.include?(skill.downcase)
      end
      
      found_skills.uniq
    end
    
    def generate_mission_statement(profile)
      return nil unless profile[:headline].present? || profile[:summary].present?
      
      # Extract key information for mission statement
      headline = profile[:headline] || ""
      summary = profile[:summary] || ""
      
      # Simple mission statement generation based on LinkedIn profile
      if headline.include?("help") || summary.include?("help")
        # User already has helping language, use it
        help_text = headline.include?("help") ? headline : summary.split('.').find { |s| s.include?("help") }
        help_text.strip if help_text
      elsif headline.present?
        # Generate from headline
        "I help businesses #{headline.downcase} through transparent and honest solutions."
      else
        nil
      end
    end
    
    def extract_picture_url(profile_picture_data)
      return nil unless profile_picture_data.present?
      
      # LinkedIn profile picture structure can be complex
      display_image = profile_picture_data.dig('displayImage~', 'elements')
      return nil unless display_image.present?
      
      # Find the largest available image
      largest_image = display_image.max_by do |element|
        element.dig('data', 'com.linkedin.digitalmedia.mediaartifact.StillImage', 'storageSize', 'width') || 0
      end
      
      largest_image&.dig('identifiers', 0, 'identifier')
    end
  end
end