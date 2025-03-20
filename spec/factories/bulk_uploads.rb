FactoryBot.define do
  factory :bulk_upload do
    status { 0 }
    total_lines { 3 }
    file { File.open(Rails.root.join('spec/support/files/factory_upload_script.txt'), filename: 'script.txt') }
    association :user
  end
end
