class ProfileSetupService
  class << self
    def setup_gary_profile(user)
      return { success: false, error: "User not found" } unless user.present?

      # Extract skills from docs/skills.md
      gary_skills = extract_gary_skills

      # Gary's bio from no-illusion-nextjs about page
      gary_bio = extract_gary_bio

      # Gary's mission statement from company values
      gary_mission = extract_gary_mission

      # Update user profile
      updates_made = []

      # Update name if not already set to Gary
      if user.name != "Gary Bracket"
        user.name = "Gary Bracket"
        updates_made << "Name"
      end

      # Update bio
      if user.bio.blank? || user.bio.length < 100
        user.bio = gary_bio
        updates_made << "Bio"
      end

      # Update skills
      current_skills = user.skills || []
      merged_skills = (current_skills + gary_skills).uniq.sort
      if merged_skills != current_skills
        user.skills = merged_skills
        updates_made << "Skills (#{gary_skills.count} added)"
      end

      # Update mission statement
      if user.mission_statement.blank? || user.mission_statement.length < 50
        user.mission_statement = gary_mission
        updates_made << "Mission Statement"
      end

      # Set business content mode if not set
      if user.content_mode != "business"
        user.content_mode = "business"
        updates_made << "Content Mode (set to Business)"
      end

      if user.save
        Rails.logger.info "Gary's profile setup completed for user #{user.id}: #{updates_made.join(', ')}"
        {
          success: true,
          updates_made: updates_made,
          message: updates_made.any? ? "Profile updated: #{updates_made.join(', ')}" : "Profile already up to date"
        }
      else
        {
          success: false,
          error: "Failed to save profile: #{user.errors.full_messages.join(', ')}"
        }
      end
    end

    def add_custom_skill(user, skill_name)
      return { success: false, error: "Skill name required" } if skill_name.blank?

      # Clean up the skill name
      skill_name = skill_name.strip.titleize

      current_skills = user.skills || []

      if current_skills.include?(skill_name)
        return { success: false, error: "Skill '#{skill_name}' already exists" }
      end

      # Add the new skill
      new_skills = (current_skills + [ skill_name ]).uniq.sort
      user.skills = new_skills

      if user.save
        Rails.logger.info "Custom skill '#{skill_name}' added for user #{user.id}"
        {
          success: true,
          message: "Skill '#{skill_name}' added successfully",
          skills: new_skills
        }
      else
        {
          success: false,
          error: "Failed to save skill: #{user.errors.full_messages.join(', ')}"
        }
      end
    end

    def remove_skill(user, skill_name)
      return { success: false, error: "Skill name required" } if skill_name.blank?

      current_skills = user.skills || []

      unless current_skills.include?(skill_name)
        return { success: false, error: "Skill '#{skill_name}' not found" }
      end

      new_skills = current_skills - [ skill_name ]
      user.skills = new_skills

      if user.save
        Rails.logger.info "Skill '#{skill_name}' removed for user #{user.id}"
        {
          success: true,
          message: "Skill '#{skill_name}' removed successfully",
          skills: new_skills
        }
      else
        {
          success: false,
          error: "Failed to remove skill: #{user.errors.full_messages.join(', ')}"
        }
      end
    end

    private

    def extract_gary_skills
      # Top skills from docs/skills.md and about page analysis
      [
        # Frontend Development
        "HTML/CSS", "JavaScript", "TypeScript", "React", "Next.js", "Tailwind CSS",
        "UI/UX Design", "Responsive Design", "Component Architecture",

        # Backend Development
        "Node.js", "Python", "Ruby on Rails", "C#/.NET", "API Development", "RESTful Services",

        # Database & Infrastructure
        "PostgreSQL", "Database Design", "Cloud Services", "Heroku", "AWS", "Docker",

        # Business & Automation
        "PowerShell", "Process Automation", "Business Automation", "System Architecture",
        "IT Consulting", "System Administration", "Active Directory", "Exchange",

        # AI & Integration
        "AI Integration", "OpenAI API", "Anthropic Claude", "Multi-Provider AI Systems",

        # Specialized
        "Healthcare Systems", "HIPAA Compliance", "Social Media APIs", "LinkedIn API",
        "Email Integration", "Background Jobs", "Real-time Systems", "Security",

        # Business Skills
        "Project Management", "IT Leadership", "Technical Communication", "System Optimization",
        "Cost Analysis", "Vendor Management", "Legacy System Migration",

        # Development Practices
        "Git", "CI/CD", "Code Quality", "Performance Optimization", "Documentation",
        "Testing", "Debugging", "Problem Solving"
      ]
    end

    def extract_gary_bio
      # Bio extracted from no-illusion-nextjs about page
      <<~BIO.strip
        IT Director & Engineer with 20+ years in technology. Started building PCs as a teenager and evolved into full-stack development and business automation.

        Associates Degree in Computer Information Systems. Currently full-time IT Director specializing in system automation, process optimization, and transparent technology solutions.

        Core expertise: Multi-platform web development (React/Next.js, Ruby/Rails, Python), business automation (PowerShell, API integration), healthcare systems (HIPAA-compliant), and AI integration (OpenAI, Anthropic, multi-provider systems).

        Philosophy: Function over Form, Patient Communication, MVP Approach. I don't memorize APIs - I weaponize patterns. Give me any stack and I'll have it deployed by coffee break.

        No Illusion Software Solutions: No games, no gimmicks, no tricks, no manipulation. Helping small businesses through honest technology and transparent practices.
      BIO
    end

    def extract_gary_mission
      # Mission from company-values.md adapted for Gary personally
      "I help small business owners build authentic technology solutions through honest development, transparent practices, and patient technical communication."
    end

    def get_available_skill_suggestions
      # Additional skills that can be suggested to users
      [
        "Marketing", "Social Media Marketing", "Content Creation", "SEO", "Analytics",
        "Graphic Design", "Copywriting", "Email Marketing", "Digital Marketing",
        "Sales", "Business Development", "Consulting", "Training", "Leadership",
        "Customer Service", "Public Speaking", "Networking", "Strategic Planning",
        "Budget Management", "Team Management", "Vendor Relations", "Risk Management"
      ]
    end
  end
end
