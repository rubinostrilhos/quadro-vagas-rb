require 'rails_helper'

RSpec.describe ProcessBulkUploadFileJob, type: :job do
  it 'correctly enqueues the job' do
    bulk_upload = BulkUpload.create(status: 0, total_lines: 3)
    file_path = Rails.root.join('spec/support/files/script.txt')

    File.open(file_path, "w") do |file|
      file.puts "U,gabriel@toledo.com,Gabriel,Toledo,1"
      file.puts "E,Microsoft,https://microsoft.com,microsoft@email.com,1"
      file.puts "V,Dev Junior,Alguma descrição,5000,brl,Mensal,Remoto,2,Remoto,1,1"
    end

    expect {
      ProcessBulkUploadFileJob.perform_later(bulk_upload.id, file_path.to_s)
    }.to have_enqueued_job(ProcessBulkUploadFileJob).with(bulk_upload.id, file_path.to_s)

    File.delete(file_path) if File.exist?(file_path)
  end

  it 'processes file lines and triggers ProcessBulkUploadDataJob' do
    user = create(:user, role: :admin)
    bulk_upload = BulkUpload.create(total_lines: 3, user: user)
    file_path = Rails.root.join('spec/support/files/script.txt')

    File.open(file_path, "w") do |file|
      file.puts "U,gabriel@toledo.com,Gabriel,Toledo,1"
      file.puts "E,Microsoft,https://microsoft.com,microsoft@email.com,1"
      file.puts "V,Dev Junior,Alguma descrição,5000,brl,Mensal,Remoto,2,Remoto,1,1"
    end

    expect {
      ProcessBulkUploadFileJob.perform_now(bulk_upload.id, file_path.to_s)
    }.to have_enqueued_job(ProcessBulkUploadDataJob).exactly(3).times

    File.delete(file_path) if File.exist?(file_path)
  end

  it 'updates bulk upload status to processing' do
    user = create(:user, role: :admin)
    bulk_upload = BulkUpload.create(status: 0, total_lines: 3, user: user)
    file_path = Rails.root.join('spec/support/files/script.txt')

    File.open(file_path, "w") do |file|
      file.puts "U,gabriel@toledo.com,Gabriel,Toledo,1"
      file.puts "E,Microsoft,https://microsoft.com,microsoft@email.com,1"
      file.puts "V,Dev Junior,Alguma descrição,5000,brl,Mensal,Remoto,2,Remoto,1,1"
    end

    ProcessBulkUploadFileJob.perform_now(bulk_upload.id, file_path.to_s)

    expect(bulk_upload.reload.status).to eq("processing")

    File.delete(file_path) if File.exist?(file_path)
  end

  it 'removes the file after processing' do
    user = create(:user, role: :admin)
    bulk_upload = BulkUpload.create(total_lines: 3, user: user)
    file_path = Rails.root.join('spec/support/files/script.txt')

    File.open(file_path, "w") do |file|
      file.puts "U,gabriel@toledo.com,Gabriel,Toledo,1"
      file.puts "E,Microsoft,https://microsoft.com,microsoft@email.com"
      file.puts "V,Dev Junior,Alguma descrição,5000,brl,Mensal,Remoto,2,Remoto,1,1"
    end

    ProcessBulkUploadFileJob.perform_now(bulk_upload.id, file_path.to_s)

    expect(File.exist?(file_path)).to be false
  end
end
