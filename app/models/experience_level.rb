class ExperienceLevel < ApplicationRecord
  validates :name, presence: true
  validates :name, uniqueness: true

  enum :status, { archived: 0, active: 10 }

  has_many :job_postings
end
