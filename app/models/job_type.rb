class JobType < ApplicationRecord
  enum :status, { active: 0, archived: 10 }, default: :active
  has_many :job_postings
  validates :name, presence: true
  validates :name, uniqueness: true
end
