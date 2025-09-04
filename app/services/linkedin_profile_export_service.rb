require "net/http"
require "json"

class LinkedinProfileExportService
  class << self
    def export_profile_data(user)
      connection = user.linkedin_connection

      unless connection&.valid_connection?
        return { success: false, error: "No valid LinkedIn connection found" }
      end

      # LinkedIn API doesn't allow profile updates anymore
      # Instead, we'll generate an AI-powered LinkedIn bio/summary
      formatted_profile = generate_ai_powered_bio(user)

      {
        success: true,
        formatted_profile: formatted_profile,
        message: "Generated AI-powered LinkedIn bio ready for copy & paste!"
      }
    end

    def generate_ai_powered_bio(user)
      # Use AI to generate a professional LinkedIn bio based on user's profile
      prompt = build_linkedin_bio_prompt(user)

      # Generate AI content using the existing AI service
      ai_result = AiContentService.generate_post(
        user: user,
        prompt: prompt,
        platform: "linkedin"
      )

      if ai_result[:success]
        bio_content = ai_result[:content]

        # Format for LinkedIn with sections
        {
          headline: extract_headline(bio_content),
          about_section: format_about_section(bio_content),
          raw_content: bio_content,
          copy_paste_ready: format_for_copy_paste(bio_content)
        }
      else
        # Fallback to manual generation if AI fails
        generate_formatted_profile(user)
      end
    end

    def generate_formatted_profile(user)
      # Generate a professionally formatted profile that users can copy-paste to LinkedIn
      profile_sections = {}

      # Professional Headline
      if user.mission_statement.present?
        profile_sections[:headline] = user.mission_statement
      elsif user.bio.present?
        # Extract first sentence or key phrase from bio
        first_sentence = user.bio.split(".").first&.strip
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
        "JavaScript", "TypeScript", "React", "Next.js", "Node.js", "Python", "Ruby", "Rails",
        "HTML", "CSS", "SQL", "PostgreSQL", "AWS", "Docker", "Git", "API", "Database",
        "PowerShell", "C#", ".NET", "Linux", "Windows", "Cloud", "DevOps", "Security"
      ]

      technical_keywords.any? { |keyword| skill.downcase.include?(keyword.downcase) }
    end

    def business_skill?(skill)
      business_keywords = [
        "Marketing", "Sales", "Management", "Leadership", "Consulting", "Strategy",
        "Project Management", "Business", "Analytics", "Communication", "Training"
      ]

      business_keywords.any? { |keyword| skill.downcase.include?(keyword.downcase) }
    end

    def build_linkedin_bio_prompt(user)
      "Create a professional LinkedIn bio/summary for #{user.name}.

User Details:
- Content Mode: #{user.content_mode.humanize}
- Mission: #{user.mission_statement.presence || 'Not specified'}
- Bio: #{user.bio.presence || 'Not specified'}
- Skills: #{user.skills&.join(', ').presence || 'Not specified'}

Requirements:
- Professional tone appropriate for LinkedIn
- 2-3 paragraphs maximum
- Highlight key strengths and experience
- Include relevant skills naturally
- End with a call-to-action for connection/contact
- Make it engaging but authentic

Generate only the bio content, no extra formatting or labels."
    end

    def extract_headline(bio_content)
      # Extract a potential headline from the first sentence
      first_sentence = bio_content.split(".").first&.strip
      if first_sentence && first_sentence.length <= 120
        first_sentence
      else
        "Professional | #{bio_content.split(' ').take(8).join(' ')}"[0..119]
      end
    end

    def format_about_section(bio_content)
      bio_content.strip
    end

    def format_for_copy_paste(bio_content)
      "=== LINKEDIN BIO (Copy & Paste Ready) ===\n\n#{bio_content}\n\n=== END BIO ==="
    end
  end
end
