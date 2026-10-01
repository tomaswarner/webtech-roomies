class User < ApplicationRecord
  has_many :properties, foreign_key: :host_id, inverse_of: :host, dependent: :restrict_with_error
  has_many :listings, through: :properties
  has_many :received_applications, through: :listings, source: :applications
  has_many :applications, foreign_key: :seeker_id, inverse_of: :seeker, dependent: :restrict_with_error
  has_many :visits, through: :applications
  has_many :reviews, foreign_key: :seeker_id, inverse_of: :seeker, dependent: :restrict_with_error
  has_many :saved_listings, foreign_key: :seeker_id, inverse_of: :seeker, dependent: :destroy
  has_many :bookmarked_listings, through: :saved_listings, source: :listing
  has_many :reports, foreign_key: :reporter_id, inverse_of: :reporter, dependent: :restrict_with_error
  has_many :resolved_reports, class_name: "Report", foreign_key: :resolved_by_id,
                              inverse_of: :resolved_by, dependent: :nullify

  enum :role, { member: "member", moderator: "moderator" }, validate: true

  before_validation :normalize_email

  validates :name, presence: true
  validates :email, presence: true, uniqueness: { case_sensitive: false },
                    format: { with: URI::MailTo::EMAIL_REGEXP }

  scope :by_name, -> { order(:name) }

  def first_name
    name.split.first
  end

  private

  def normalize_email
    self.email = email.strip.downcase if email.present?
  end
end
