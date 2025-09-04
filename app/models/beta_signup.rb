class BetaSignup < ApplicationRecord
  # Validations
  validates :email, presence: true,
                   uniqueness: { case_sensitive: false },
                   format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :name, presence: true
  validates :signup_date, presence: true

  # Enums
  enum status: {
    pending: 0,
    accepted: 1,
    rejected: 2,
    invited: 3,
    active: 4
  }

  # Scopes
  scope :recent, -> { order(signup_date: :desc) }
  scope :this_month, -> { where(signup_date: 1.month.ago..) }
  scope :this_week, -> { where(signup_date: 1.week.ago..) }

  # Callbacks
  before_validation :set_signup_date, on: :create
  before_validation :normalize_email

  # Class methods
  def self.priority_score(beta_signup)
    score = 0

    # Company adds points
    score += 3 if beta_signup.company.present?

    # Multiple platforms adds points
    platforms = beta_signup.current_platforms&.split(",")&.length || 0
    score += platforms * 2

    # Detailed challenges shows engagement
    score += 2 if beta_signup.challenges&.length.to_i > 100

    # Earlier signup gets priority
    days_ago = (Time.current - beta_signup.signup_date) / 1.day
    score += (30 - days_ago).clamp(0, 30).to_i

    score
  end

  def priority_score
    self.class.priority_score(self)
  end

  def platform_list
    current_platforms&.split(",")&.map(&:strip) || []
  end

  def platform_count
    platform_list.count
  end

  private

  def set_signup_date
    self.signup_date ||= Time.current
  end

  def normalize_email
    self.email = email&.downcase&.strip
  end
end
