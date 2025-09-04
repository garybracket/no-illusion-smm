class ResumeGeneratorService
  class << self
    def generate_html(user, options = {})
      template = options[:template] || user.resume_template || "modern"
      color_scheme = options[:color_scheme] || user.resume_color_scheme || "professional"

      # Build resume data structure
      resume_data = build_resume_data(user)

      # Generate HTML based on template
      html = case template
      when "modern"
        generate_modern_template(resume_data, color_scheme)
      when "classic"
        generate_classic_template(resume_data, color_scheme)
      when "minimal"
        generate_minimal_template(resume_data, color_scheme)
      else
        generate_modern_template(resume_data, color_scheme)
      end

      # Update generation timestamp
      user.update(
        last_resume_generated_at: Time.current,
        resume_version: (user.resume_version || 0) + 1
      )

      html
    end

    def generate_pdf(user, options = {})
      html = generate_html(user, options)

      # Convert HTML to PDF using wicked_pdf or similar
      # For now, return HTML with print styles
      {
        html: html,
        css: pdf_print_styles,
        filename: "#{user.name.parameterize}_resume_#{Date.current}.pdf"
      }
    end

    private

    def build_resume_data(user)
      {
        # Contact Info
        name: user.name,
        email: user.email,
        phone: user.phone,
        location: user.location,
        linkedin_url: user.linkedin_url,
        github_url: user.github_url,
        portfolio_url: user.portfolio_url,

        # Professional Summary (from resume or fallback to bio/mission)
        summary: user.professional_summary.presence ||
                 user.mission_statement.presence ||
                 user.bio,

        # Experience
        work_experience: user.work_experience || [],

        # Education
        education: user.education || [],

        # Skills (organized by category)
        skills: organize_skills(user.skills || []),

        # Certifications
        certifications: user.certifications || []
      }
    end

    def organize_skills(skills_array)
      return [] if skills_array.blank?

      # Categorize skills
      categories = {
        "Languages" => [],
        "Frameworks" => [],
        "Databases" => [],
        "Tools" => [],
        "Business" => [],
        "Other" => []
      }

      skills_array.each do |skill|
        if programming_language?(skill)
          categories["Languages"] << skill
        elsif framework?(skill)
          categories["Frameworks"] << skill
        elsif database?(skill)
          categories["Databases"] << skill
        elsif tool?(skill)
          categories["Tools"] << skill
        elsif business_skill?(skill)
          categories["Business"] << skill
        else
          categories["Other"] << skill
        end
      end

      # Remove empty categories
      categories.reject { |_, v| v.empty? }
    end

    def programming_language?(skill)
      languages = [ "Ruby", "Python", "JavaScript", "TypeScript", "Java", "C#", "C++", "Go", "Rust", "PHP", "Swift", "Kotlin", "HTML", "CSS", "SQL" ]
      languages.any? { |lang| skill.downcase.include?(lang.downcase) }
    end

    def framework?(skill)
      frameworks = [ "Rails", "React", "Angular", "Vue", "Next.js", "Express", "Django", "Flask", "Spring", ".NET", "Laravel", "Tailwind", "Bootstrap" ]
      frameworks.any? { |fw| skill.downcase.include?(fw.downcase) }
    end

    def database?(skill)
      databases = [ "PostgreSQL", "MySQL", "MongoDB", "Redis", "Elasticsearch", "DynamoDB", "SQL Server", "Oracle", "Cassandra" ]
      databases.any? { |db| skill.downcase.include?(db.downcase) }
    end

    def tool?(skill)
      tools = [ "Git", "Docker", "Kubernetes", "AWS", "Azure", "GCP", "Jenkins", "Terraform", "Ansible", "Linux", "Jira", "Figma" ]
      tools.any? { |tool| skill.downcase.include?(tool.downcase) }
    end

    def business_skill?(skill)
      business = [ "Marketing", "Sales", "Management", "Leadership", "Project Management", "Agile", "Scrum", "Communication", "Strategy" ]
      business.any? { |bs| skill.downcase.include?(bs.downcase) }
    end

    def generate_modern_template(data, color_scheme)
      colors = get_color_scheme(color_scheme)

      <<~HTML
        <!DOCTYPE html>
        <html>
        <head>
          <meta charset="UTF-8">
          <title>#{data[:name]} - Resume</title>
          <style>
            #{modern_template_styles(colors)}
          </style>
        </head>
        <body>
          <div class="resume-container">
            <!-- Header Section -->
            <header class="header">
              <h1 class="name">#{data[:name]}</h1>
              <div class="contact-info">
                #{build_contact_line(data)}
              </div>
              <div class="links">
                #{build_links_line(data)}
              </div>
            </header>
        #{'    '}
            <!-- Professional Summary -->
            #{build_summary_section(data[:summary]) if data[:summary].present?}
        #{'    '}
            <!-- Work Experience -->
            #{build_experience_section(data[:work_experience]) if data[:work_experience].any?}
        #{'    '}
            <!-- Education -->
            #{build_education_section(data[:education]) if data[:education].any?}
        #{'    '}
            <!-- Skills -->
            #{build_skills_section(data[:skills]) if data[:skills].any?}
        #{'    '}
            <!-- Certifications -->
            #{build_certifications_section(data[:certifications]) if data[:certifications].any?}
          </div>
        </body>
        </html>
      HTML
    end

    def modern_template_styles(colors)
      <<~CSS
        * {
          margin: 0;
          padding: 0;
          box-sizing: border-box;
        }

        body {
          font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
          line-height: 1.6;
          color: #333;
          background: white;
        }

        .resume-container {
          max-width: 800px;
          margin: 0 auto;
          padding: 40px;
          min-height: 100vh;
        }

        /* Keep it to one page for print */
        @media print {
          .resume-container {
            padding: 20px;
            max-width: 100%;
          }
        #{'  '}
          body {
            font-size: 11pt;
          }
        #{'  '}
          .section {
            page-break-inside: avoid;
          }
        }

        .header {
          border-bottom: 3px solid #{colors[:primary]};
          padding-bottom: 20px;
          margin-bottom: 20px;
        }

        .name {
          font-size: 32px;
          color: #{colors[:primary]};
          margin-bottom: 10px;
        }

        .contact-info {
          font-size: 14px;
          color: #666;
          margin-bottom: 5px;
        }

        .links {
          font-size: 14px;
        }

        .links a {
          color: #{colors[:accent]};
          text-decoration: none;
          margin-right: 15px;
        }

        .section {
          margin-bottom: 25px;
        }

        .section-title {
          font-size: 18px;
          color: #{colors[:primary]};
          border-bottom: 2px solid #{colors[:light]};
          padding-bottom: 5px;
          margin-bottom: 15px;
          text-transform: uppercase;
          letter-spacing: 1px;
        }

        .experience-item, .education-item {
          margin-bottom: 20px;
        }

        .item-header {
          display: flex;
          justify-content: space-between;
          margin-bottom: 5px;
        }

        .position {
          font-weight: bold;
          color: #333;
        }

        .company {
          color: #{colors[:accent]};
          font-weight: 500;
        }

        .dates {
          color: #666;
          font-size: 14px;
        }

        .responsibilities {
          margin-left: 20px;
          margin-top: 5px;
        }

        .responsibilities li {
          margin-bottom: 3px;
          color: #555;
        }

        .skills-grid {
          display: grid;
          grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
          gap: 15px;
        }

        .skill-category {
          margin-bottom: 10px;
        }

        .skill-category-title {
          font-weight: bold;
          color: #{colors[:accent]};
          margin-bottom: 5px;
        }

        .skill-list {
          color: #555;
          font-size: 14px;
        }

        .certifications-list {
          list-style: none;
          padding-left: 0;
        }

        .certifications-list li {
          margin-bottom: 5px;
          color: #555;
        }

        .certifications-list li:before {
          content: "▸ ";
          color: #{colors[:accent]};
          font-weight: bold;
        }
      CSS
    end

    def get_color_scheme(scheme)
      case scheme
      when "professional"
        { primary: "#2c3e50", accent: "#3498db", light: "#ecf0f1" }
      when "modern"
        { primary: "#1a1a2e", accent: "#16213e", light: "#e94560" }
      when "creative"
        { primary: "#6c5ce7", accent: "#a29bfe", light: "#dfe6e9" }
      else
        { primary: "#2c3e50", accent: "#3498db", light: "#ecf0f1" }
      end
    end

    def build_contact_line(data)
      parts = []
      parts << data[:email] if data[:email].present?
      parts << data[:phone] if data[:phone].present?
      parts << data[:location] if data[:location].present?
      parts.join(" • ")
    end

    def build_links_line(data)
      links = []
      links << "<a href='#{data[:linkedin_url]}'>LinkedIn</a>" if data[:linkedin_url].present?
      links << "<a href='#{data[:github_url]}'>GitHub</a>" if data[:github_url].present?
      links << "<a href='#{data[:portfolio_url]}'>Portfolio</a>" if data[:portfolio_url].present?
      links.join(" • ")
    end

    def build_summary_section(summary)
      <<~HTML
        <section class="section">
          <h2 class="section-title">Professional Summary</h2>
          <p>#{summary}</p>
        </section>
      HTML
    end

    def build_experience_section(experiences)
      return "" if experiences.blank?

      items_html = experiences.map do |exp|
        <<~HTML
          <div class="experience-item">
            <div class="item-header">
              <div>
                <span class="position">#{exp['position']}</span>
                #{ exp['company'] ? "at <span class='company'>#{exp['company']}</span>" : '' }
              </div>
              <span class="dates">#{exp['start_date']} - #{exp['end_date']}</span>
            </div>
            #{build_responsibilities_list(exp['responsibilities'])}
          </div>
        HTML
      end.join("\n")

      <<~HTML
        <section class="section">
          <h2 class="section-title">Professional Experience</h2>
          #{items_html}
        </section>
      HTML
    end

    def build_responsibilities_list(responsibilities)
      return "" if responsibilities.blank?

      items = responsibilities.map { |r| "<li>#{r}</li>" }.join("\n")
      "<ul class='responsibilities'>#{items}</ul>"
    end

    def build_education_section(education)
      return "" if education.blank?

      items_html = education.map do |edu|
        gpa_text = edu["gpa"] ? " • GPA: #{edu['gpa']}" : ""
        <<~HTML
          <div class="education-item">
            <div class="item-header">
              <div>
                <span class="position">#{edu['degree']}</span>
                #{ edu['field'] ? "in #{edu['field']}" : '' }
              </div>
              <span class="dates">#{edu['graduation_date']}#{gpa_text}</span>
            </div>
            <div class="company">#{edu['school']}</div>
          </div>
        HTML
      end.join("\n")

      <<~HTML
        <section class="section">
          <h2 class="section-title">Education</h2>
          #{items_html}
        </section>
      HTML
    end

    def build_skills_section(skills_by_category)
      return "" if skills_by_category.blank?

      categories_html = skills_by_category.map do |category, skills|
        <<~HTML
          <div class="skill-category">
            <div class="skill-category-title">#{category}</div>
            <div class="skill-list">#{skills.join(', ')}</div>
          </div>
        HTML
      end.join("\n")

      <<~HTML
        <section class="section">
          <h2 class="section-title">Technical Skills</h2>
          <div class="skills-grid">
            #{categories_html}
          </div>
        </section>
      HTML
    end

    def build_certifications_section(certifications)
      return "" if certifications.blank?

      items = certifications.map { |cert| "<li>#{cert}</li>" }.join("\n")

      <<~HTML
        <section class="section">
          <h2 class="section-title">Certifications</h2>
          <ul class="certifications-list">
            #{items}
          </ul>
        </section>
      HTML
    end

    def pdf_print_styles
      <<~CSS
        @media print {
          @page {
            size: letter;
            margin: 0.5in;
          }
        #{'  '}
          body {
            print-color-adjust: exact;
            -webkit-print-color-adjust: exact;
          }
        }
      CSS
    end
  end
end
