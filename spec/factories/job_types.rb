FactoryBot.define do
  factory :job_type do
    sequence(:name) { |n| "Job Type #{n}" }
  end
end
