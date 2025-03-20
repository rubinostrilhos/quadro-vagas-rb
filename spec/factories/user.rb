FactoryBot.define do
  factory :user do
    name { 'João' }
    last_name { 'Silva' }
    sequence(:email_address) { |n| "joao#{n}@email.com" }
    password { 'password123' }
    password_confirmation { 'password123' }
    role { :regular }
    status { :active }
  end
end
