FactoryBot.define do
  factory :company_profile do
    association :user
    name { "BlinkedOn" }
    sequence(:contact_email) { |n| "contact#{n}@blinkedon.tech" }
    sequence(:website_url) { |n| "https://blinkedon#{n}.tech" }
    logo { File.open(Rails.root.join('spec/support/files/logo.jpg'), filename: 'logo.jpg') }
  end
end
