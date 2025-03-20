FactoryBot.define do
  factory :bulk_upload do
    status { 0 }
    total_lines { 3 }
    association :user

    after(:build) do |bulk_upload|
      file_path = Rails.root.join('tmp/factory_upload_script.txt')

      File.open(file_path, "w") do |file|
        file.puts "U,gabriel@toledo.com,Gabriel,Toledo,1"
        file.puts "E,Microsoft,https://microsoft.com,microsoft@email.com,1"
      end

      bulk_upload.file.attach(io: File.open(file_path), filename: 'script.txt', content_type: 'text/plain')
    end
  end
end
