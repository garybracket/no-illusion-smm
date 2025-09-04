class AddResumeFieldsToUsers < ActiveRecord::Migration[7.2]
  def change
    # Professional Summary (elevator pitch)
    add_column :users, :professional_summary, :text

    # Work Experience (array of JSON objects)
    add_column :users, :work_experience, :json, default: []
    # Structure: [{
    #   company: "Company Name",
    #   position: "Job Title",
    #   location: "City, State",
    #   start_date: "MM/YYYY",
    #   end_date: "MM/YYYY" or "Present",
    #   responsibilities: ["Achievement 1", "Achievement 2"],
    #   technologies: ["Tech 1", "Tech 2"]
    # }]

    # Education (array of JSON objects)
    add_column :users, :education, :json, default: []
    # Structure: [{
    #   school: "University Name",
    #   degree: "Bachelor of Science",
    #   field: "Computer Science",
    #   graduation_date: "MM/YYYY",
    #   gpa: "3.9",
    #   achievements: ["Dean's List", "Honors"]
    # }]

    # Certifications (simple array)
    add_column :users, :certifications, :json, default: []
    # Structure: ["AWS Certified", "PMP", "etc"]

    # Contact Information
    add_column :users, :phone, :string
    add_column :users, :linkedin_url, :string
    add_column :users, :github_url, :string
    add_column :users, :portfolio_url, :string
    add_column :users, :location, :string # "City, State"

    # Resume preferences
    add_column :users, :resume_template, :string, default: 'modern'
    add_column :users, :resume_color_scheme, :string, default: 'professional'

    # Last resume generation metadata (for caching)
    add_column :users, :last_resume_generated_at, :datetime
    add_column :users, :resume_version, :integer, default: 1
  end
end
