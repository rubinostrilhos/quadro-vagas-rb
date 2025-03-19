FactoryBot.define do
  factory :bulk_upload do
    status { 1 }
    total_lines { 1 }
    errors_count { 1 }
    file { "MyString" }
    user { nil }
  end
end
