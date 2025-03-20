FactoryBot.define do
  factory :bulk_upload_error do
    line { 1 }
    message { "Error processing line" }
    association :bulk_upload
  end
end
