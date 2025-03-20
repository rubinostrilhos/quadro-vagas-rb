FactoryBot.define do
  factory :experience_level do
    sequence(:name) { |n| "Experience Level #{n}" }
    status { :active }
  end
end
