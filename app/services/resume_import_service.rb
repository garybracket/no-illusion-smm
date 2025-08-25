require 'pdf-reader' # We'll need to add this gem
require 'docx' # For Word docs

class ResumeImportService
  class << self
    # Process uploaded file WITHOUT storing it
    def import_from_file(user, uploaded_file)
      return { success: false, error: "No file provided" } unless uploaded_file.present?
      
      # Read file content into memory
      content = uploaded_file.read
      filename = uploaded_file.original_filename.downcase
      
      # Process based on file type
      parsed_data = if filename.ends_with?('.pdf')
        parse_pdf(content)
      elsif filename.ends_with?('.docx', '.doc')
        parse_word(content)
      elsif filename.ends_with?('.txt')
        parse_text(content)
      else
        return { success: false, error: "Unsupported file format. Please upload PDF, Word, or TXT." }
      end
      
      # File is now discarded (not stored anywhere)
      
      # Update user profile with parsed data
      update_user_from_resume(user, parsed_data)
    rescue => e
      Rails.logger.error "Resume import error: #{e.message}"
      { success: false, error: "Failed to parse resume: #{e.message}" }
    end
    
    # Import from plain text (for copy-paste)
    def import_from_text(user, resume_text)
      parsed_data = parse_text(resume_text)
      update_user_from_resume(user, parsed_data)
    end
    
    private
    
    def parse_pdf(content)
      # PRIVACY: Process PDF in memory, never save to disk
      text = ""
      
      # Create StringIO from content for PDF::Reader
      io = StringIO.new(content)
      reader = PDF::Reader.new(io)
      reader.pages.each do |page|
        text += page.text + "\n"
      end
      
      extract_resume_sections(text)
    end
    
    def parse_word(content)
      # For now, return basic parsing
      # Would need python-docx2txt or similar gem
      extract_resume_sections(content.force_encoding('UTF-8'))
    end
    
    def parse_text(text)
      extract_resume_sections(text)
    end
    
    def extract_resume_sections(text)
      data = {}
      
      # Extract contact info
      data[:email] = extract_email(text)
      data[:phone] = extract_phone(text)
      data[:linkedin_url] = extract_linkedin_url(text)
      data[:github_url] = extract_github_url(text)
      
      # Extract name (usually first line or near email)
      data[:name] = extract_name(text)
      
      # Extract sections
      data[:professional_summary] = extract_section(text, 
        ['summary', 'objective', 'profile', 'about'])
      
      data[:work_experience] = extract_work_experience(text)
      data[:education] = extract_education(text)
      data[:skills] = extract_skills(text)
      data[:certifications] = extract_certifications(text)
      
      data
    end
    
    def extract_email(text)
      email_regex = /[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+/i
      match = text.match(email_regex)
      match[0] if match
    end
    
    def extract_phone(text)
      # Match various phone formats
      phone_regex = /(\+?\d{1,3}[-.\s]?)?\(?\d{3}\)?[-.\s]?\d{3}[-.\s]?\d{4}/
      match = text.match(phone_regex)
      match[0].gsub(/[^\d+]/, '') if match # Clean format
    end
    
    def extract_linkedin_url(text)
      linkedin_regex = /(?:https?:\/\/)?(?:www\.)?linkedin\.com\/in\/[\w\-]+/i
      match = text.match(linkedin_regex)
      match[0] if match
    end
    
    def extract_github_url(text)
      github_regex = /(?:https?:\/\/)?(?:www\.)?github\.com\/[\w\-]+/i
      match = text.match(github_regex)
      match[0] if match
    end
    
    def extract_name(text)
      # Usually the first non-empty line or line before/after email
      lines = text.split("\n").reject(&:blank?)
      
      # Look for line that's likely a name (2-4 words, no special chars except space)
      name_line = lines.find do |line|
        words = line.split(' ')
        words.length.between?(2, 4) && 
        line.match?(/^[A-Za-z\s\-\.]+$/) &&
        !line.downcase.include?('@') # Not email line
      end
      
      name_line&.strip
    end
    
    def extract_section(text, keywords)
      # Find section by keywords
      keywords.each do |keyword|
        regex = /#{keyword}:?\s*\n(.*?)(?=\n[A-Z][A-Z\s]{2,}:|$)/im
        match = text.match(regex)
        return match[1].strip if match && match[1]
      end
      nil
    end
    
    def extract_work_experience(text)
      experiences = []
      
      # Look for work/experience section
      section_regex = /(?:work\s+)?experience:?\s*\n(.*?)(?=\n[A-Z][A-Z\s]{2,}:|education|skills|$)/im
      section_match = text.match(section_regex)
      return experiences unless section_match
      
      section_text = section_match[1]
      
      # Parse individual jobs (this is simplified - real parsing is complex)
      job_blocks = section_text.split(/\n{2,}/)
      
      job_blocks.each do |block|
        lines = block.split("\n").reject(&:blank?)
        next if lines.empty?
        
        experience = {}
        
        # First line often has position and company
        first_line = lines[0]
        if first_line.include?(' at ') || first_line.include?(' - ')
          parts = first_line.split(/\s+at\s+|\s+-\s+/)
          experience[:position] = parts[0].strip if parts[0]
          experience[:company] = parts[1].strip if parts[1]
        else
          experience[:position] = first_line.strip
          experience[:company] = lines[1].strip if lines[1]
        end
        
        # Look for dates (MM/YYYY - MM/YYYY or similar)
        date_regex = /(\d{1,2}\/\d{4}|\w+\s+\d{4})\s*[-–]\s*(\d{1,2}\/\d{4}|\w+\s+\d{4}|Present|Current)/i
        date_match = block.match(date_regex)
        if date_match
          experience[:start_date] = date_match[1]
          experience[:end_date] = date_match[2]
        end
        
        # Remaining lines are usually responsibilities
        responsibility_lines = lines[2..-1] || []
        experience[:responsibilities] = responsibility_lines
          .map { |l| l.sub(/^[•\-*]\s*/, '').strip }
          .reject(&:blank?)
        
        experiences << experience if experience[:position] || experience[:company]
      end
      
      experiences
    end
    
    def extract_education(text)
      education_list = []
      
      # Look for education section
      section_regex = /education:?\s*\n(.*?)(?=\n[A-Z][A-Z\s]{2,}:|skills|certifications|$)/im
      section_match = text.match(section_regex)
      return education_list unless section_match
      
      section_text = section_match[1]
      
      # Parse individual education entries
      edu_blocks = section_text.split(/\n{2,}/)
      
      edu_blocks.each do |block|
        lines = block.split("\n").reject(&:blank?)
        next if lines.empty?
        
        education = {}
        
        # Look for degree (Bachelor, Master, Associate, etc.)
        degree_regex = /(Bachelor|Master|Associate|B\.?S\.?|M\.?S\.?|B\.?A\.?|M\.?A\.?|Ph\.?D)/i
        degree_match = block.match(degree_regex)
        
        if degree_match
          degree_line = lines.find { |l| l.include?(degree_match[0]) }
          education[:degree] = degree_line.strip if degree_line
          
          # School is often the other main line
          school_line = lines.find { |l| l != degree_line && l.length > 10 }
          education[:school] = school_line.strip if school_line
        else
          # Assume first line is school
          education[:school] = lines[0].strip
          education[:degree] = lines[1].strip if lines[1]
        end
        
        # Look for GPA
        gpa_match = block.match(/GPA:?\s*([\d.]+)/i)
        education[:gpa] = gpa_match[1] if gpa_match
        
        # Look for graduation date
        year_match = block.match(/\b(19|20)\d{2}\b/)
        education[:graduation_date] = year_match[0] if year_match
        
        education_list << education if education[:school] || education[:degree]
      end
      
      education_list
    end
    
    def extract_skills(text)
      skills = []
      
      # Look for skills section
      section_regex = /(?:technical\s+)?skills:?\s*\n(.*?)(?=\n[A-Z][A-Z\s]{2,}:|$)/im
      section_match = text.match(section_regex)
      return skills unless section_match
      
      section_text = section_match[1]
      
      # Skills are often comma or bullet separated
      # Remove bullets and split
      skills_text = section_text.gsub(/[•\-*]/, '').gsub(/\n/, ', ')
      skills = skills_text.split(/[,;]/).map(&:strip).reject(&:blank?)
      
      # Clean up and limit
      skills.take(30)
    end
    
    def extract_certifications(text)
      certs = []
      
      # Look for certifications section
      section_regex = /certifications?:?\s*\n(.*?)(?=\n[A-Z][A-Z\s]{2,}:|$)/im
      section_match = text.match(section_regex)
      return certs unless section_match
      
      section_text = section_match[1]
      
      # Each line is usually a certification
      certs = section_text.split("\n")
        .map { |l| l.sub(/^[•\-*]\s*/, '').strip }
        .reject(&:blank?)
        .take(10)
      
      certs
    end
    
    def update_user_from_resume(user, parsed_data)
      # Update user with non-blank parsed data
      user.name = parsed_data[:name] if parsed_data[:name].present?
      user.email = parsed_data[:email] if parsed_data[:email].present? && user.email.blank?
      user.phone = parsed_data[:phone] if parsed_data[:phone].present?
      user.linkedin_url = parsed_data[:linkedin_url] if parsed_data[:linkedin_url].present?
      user.github_url = parsed_data[:github_url] if parsed_data[:github_url].present?
      
      # Professional summary
      if parsed_data[:professional_summary].present?
        user.professional_summary = parsed_data[:professional_summary]
      end
      
      # Work experience
      if parsed_data[:work_experience].present? && parsed_data[:work_experience].any?
        user.work_experience = parsed_data[:work_experience]
      end
      
      # Education
      if parsed_data[:education].present? && parsed_data[:education].any?
        user.education = parsed_data[:education]
      end
      
      # Skills - merge with existing
      if parsed_data[:skills].present? && parsed_data[:skills].any?
        existing_skills = user.skills || []
        user.skills = (existing_skills + parsed_data[:skills]).uniq
      end
      
      # Certifications
      if parsed_data[:certifications].present? && parsed_data[:certifications].any?
        user.certifications = parsed_data[:certifications]
      end
      
      if user.save
        {
          success: true,
          message: "Resume imported successfully",
          imported_fields: parsed_data.keys.select { |k| parsed_data[k].present? }
        }
      else
        {
          success: false,
          error: "Failed to update profile: #{user.errors.full_messages.join(', ')}"
        }
      end
    end
  end
end