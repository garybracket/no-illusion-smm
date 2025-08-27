# Setup production profile for Gary McQueen
user = User.find_or_initialize_by(email: 'real.ener.g@gmail.com')

# Set all profile attributes to match local
user.update!(
  name: 'Gary McQueen',
  content_mode: 'business',
  ai_enabled: true,
  mission_statement: 'I help small business owners build authentic technology solutions through honest development, transparent practices, and patient technical communication.',
  bio: 'IT Director & Engineer with 20+ years in technology. Started building PCs as a teenager and evolved into full-stack development and business automation.

Associates Degree in Computer Information Systems. Currently full-time IT Director specializing in system automation, process optimization, and transparent technology solutions.

Core expertise: Multi-platform web development (React/Next.js, Ruby/Rails, Python), business automation (PowerShell, API integration), healthcare systems (HIPAA-compliant), and AI integration (OpenAI, Anthropic, multi-provider systems).

Philosophy: Function over Form, Patient Communication, MVP Approach. I don\'t memorize APIs - I weaponize patterns. Give me any stack and I\'ll have it deployed by coffee break.

No Illusion Software Solutions: No games, no gimmicks, no tricks, no manipulation. Helping small businesses through honest technology and transparent practices.',
  skills: ['AI Integration', 'API Development', 'AWS', 'Active Directory', 'Anthropic Claude', 'Background Jobs', 'Business Automation', 'C#/.NET', 'CI/CD', 'Cloud Services', 'Code Quality', 'Component Architecture', 'Cost Analysis', 'Database Design', 'Debugging', 'Docker', 'Documentation', 'Email Integration', 'Exchange', 'Git', 'HIPAA Compliance', 'HTML/CSS', 'Healthcare Systems', 'Heroku', 'IT Consulting', 'IT Leadership', 'JavaScript', 'Legacy System Migration', 'LinkedIn API', 'Multi-Provider AI Systems', 'Next.js', 'Node.js', 'OpenAI API', 'Performance Optimization', 'PostgreSQL', 'PowerShell', 'Problem Solving', 'Process Automation', 'Project Management', 'Python', 'RESTful Services', 'React', 'Real-time Systems', 'Responsive Design', 'Ruby on Rails', 'Security', 'Social Media APIs', 'System Administration', 'System Architecture', 'System Optimization', 'Tailwind CSS', 'Technical Communication', 'Testing', 'TypeScript', 'UI/UX Design', 'Vendor Management'],
  password: Devise.friendly_token[0, 20]
)

puts '=== Production Profile Created/Updated ==='
puts "ID: #{user.id}"
puts "Email: #{user.email}"
puts "Name: #{user.name}"
puts "Content Mode: #{user.content_mode}"
puts "AI Enabled: #{user.ai_enabled}"
puts "Skills Count: #{user.skills&.length || 0}"
puts "Mission Statement Length: #{user.mission_statement&.length || 0} chars"
puts "Bio Length: #{user.bio&.length || 0} chars"
puts "Created: #{user.created_at}"
puts "Updated: #{user.updated_at}"