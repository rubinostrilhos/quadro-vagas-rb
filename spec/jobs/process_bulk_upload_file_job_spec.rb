require 'rails_helper'

RSpec.describe ProcessBulkUploadFileJob, type: :job do
  it 'correctly enqueues the job' do
    bulk_upload = BulkUpload.create(status: 0, total_lines: 3)
    file_path = Rails.root.join('spec/support/files/script.txt')

    File.open(file_path, "w") do |file|
      file.puts "U,usuario@example.com,Nome,Sobrenome,senha123"
      file.puts "E,Empresa X,https://empresa-x.com,contato@empresa-x.com,1"
      file.puts "V,Desenvolvedor,5000,BRL,Mensal,Presencial,1,São Paulo,1,1,Descrição"
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
      file.puts "U,usuario@example.com,Nome,Sobrenome,senha123"
      file.puts "E,Empresa X,https://empresa-x.com,contato@empresa-x.com,1"
      file.puts "V,Desenvolvedor,5000,BRL,Mensal,Presencial,1,São Paulo,1,1,Descrição"
    end

    expect {
      ProcessBulkUploadFileJob.perform_now(bulk_upload.id, file_path.to_s)
    }.to have_enqueued_job(ProcessBulkUploadDataJob).exactly(3).times

    File.delete(file_path) if File.exist?(file_path)
  end

  it 'updates bulk upload status to processing and completed' do
    user = create(:user, role: :admin)
    bulk_upload = BulkUpload.create(status: 0, total_lines: 3, user: user)
    file_path = Rails.root.join('spec/support/files/script.txt')

    File.open(file_path, "w") do |file|
      file.puts "U,usuario@example.com,Nome,Sobrenome,senha123"
      file.puts "E,Empresa X,https://empresa-x.com,contato@empresa-x.com,1"
      file.puts "V,Desenvolvedor,5000,BRL,Mensal,Presencial,1,São Paulo,1,1,Descrição"
    end

    ProcessBulkUploadFileJob.perform_now(bulk_upload.id, file_path.to_s)

    expect(bulk_upload.reload.status).to eq("completed")

    File.delete(file_path) if File.exist?(file_path)
  end

  it 'removes the file after processing' do
    user = create(:user, role: :admin)
    bulk_upload = BulkUpload.create(total_lines: 3, user: user)
    file_path = Rails.root.join('spec/support/files/script.txt')

    File.open(file_path, "w") do |file|
      file.puts "U,usuario@example.com,Nome,Sobrenome,senha123"
      file.puts "E,Empresa X,https://empresa-x.com,contato@empresa-x.com,1"
      file.puts "V,Desenvolvedor,5000,BRL,Mensal,Presencial,1,São Paulo,1,1,Descrição"
    end

    ProcessBulkUploadFileJob.perform_now(bulk_upload.id, file_path.to_s)

    expect(File.exist?(file_path)).to be false
  end
end
