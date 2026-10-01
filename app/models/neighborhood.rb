class Neighborhood < ApplicationRecord
  has_many :properties, dependent: :restrict_with_error
  has_many :listings, through: :properties

  validates :name, presence: true, uniqueness: { case_sensitive: false }

  scope :by_name, -> { order(:name) }

  def to_s
    name
  end
end
