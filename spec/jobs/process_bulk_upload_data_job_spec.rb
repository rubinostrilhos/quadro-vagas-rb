require 'rails_helper'

RSpec.describe ProcessBulkUploadDataJob, type: :job do
  it 'correctly enqueues the job' do
    admin_user = create(:user, role: :admin)
    bulk_upload = BulkUpload.create(total_lines: 1, user: admin_user)
    line = "U,usuario@example.com,Nome,Sobrenome,senha123"

    expect {
      ProcessBulkUploadDataJob.perform_later(bulk_upload.id, 0, line)
    }.to have_enqueued_job(ProcessBulkUploadDataJob).with(bulk_upload.id, 0, line)
  end

  it 'creates a user successfully' do
    admin_user = create(:user, role: :admin)
    bulk_upload = BulkUpload.create(total_lines: 1, user: admin_user)
    line = "U,usuario@example.com,Nome,Sobrenome,senha123"

    expect {
      ProcessBulkUploadDataJob.perform_now(bulk_upload.id, 0, line)
    }.to change(User, :count).by(1)
  end

  it 'creates a company successfully' do
    admin_user = create(:user, role: :admin)
    bulk_upload = BulkUpload.create(total_lines: 1, user: admin_user)
    user = User.create(name: "User", last_name: 'Example', email_address: "regularuser@example.com", password: "password", password_confirmation: "password")
    line = "E,Empresa X,https://empresa-x.com,contato@empresa-x.com,#{user.id}"

    expect {
      ProcessBulkUploadDataJob.perform_now(bulk_upload.id, 0, line)
    }.to change(CompanyProfile, :count).by(1)
  end

  it 'creates a job posting successfully' do
    admin_user = create(:user, role: :admin)
    bulk_upload = BulkUpload.create(total_lines: 1, user: admin_user)
    user = User.create(name: "User", last_name: 'Example', email_address: "regularuser@example.com", password: "password", password_confirmation: "password")
    company = create(:company_profile, user: user)
    job_type = JobType.create(name: "Full-time")
    experience_level = ExperienceLevel.create(name: "Júnior")

    line = "V,Desenvolvedor,Descrição,5000,brl,Mensal,Remoto,#{job_type.id},São Paulo,#{experience_level.id},#{company.id}"

    expect {
      ProcessBulkUploadDataJob.perform_now(bulk_upload.id, 0, line)
    }.to change(JobPosting, :count).by(1)
  end

  it 'correctly updates counters in Redis' do
    admin_user = create(:user, role: :admin)
    bulk_upload = BulkUpload.create(total_lines: 1, user: admin_user)
    line = "U,usuario@example.com,Nome,Sobrenome,senha123"
    redis = Redis.new(url: ENV["REDIS_URL"])

    redis.set("bulk-upload-#{bulk_upload.id}-processed-lines", 0)
    redis.set("bulk-upload-#{bulk_upload.id}-successful", 0)
    redis.set("bulk-upload-#{bulk_upload.id}-errors-count", 0)

    ProcessBulkUploadDataJob.perform_now(bulk_upload.id, 0, line)

    expect(redis.get("bulk-upload-#{bulk_upload.id}-processed-lines").to_i).to eq(1)
    expect(redis.get("bulk-upload-#{bulk_upload.id}-successful").to_i).to eq(1)
    expect(redis.get("bulk-upload-#{bulk_upload.id}-errors-count").to_i).to eq(0)
  end

  it 'logs an error when data is invalid' do
    admin_user = create(:user, role: :admin)
    bulk_upload = BulkUpload.create(total_lines: 1, user: admin_user)
    line = "U,,Nome,Sobrenome,senha123"

    redis = Redis.new(url: ENV["REDIS_URL"])
    redis.set("bulk-upload-#{bulk_upload.id}-errors-details", [].to_json)

    ProcessBulkUploadDataJob.perform_now(bulk_upload.id, 0, line)

    errors_details = JSON.parse(redis.get("bulk-upload-#{bulk_upload.id}-errors-details"))

    expect(errors_details.any? { |e| e.include?("Linha 1") }).to be_truthy
  end

  it 'updates bulk upload error count correctly' do
    admin_user = create(:user, role: :admin)
    bulk_upload = BulkUpload.create!(total_lines: 1, user: admin_user)
    line = "U,,Nome,Sobrenome,senha123"

    expect {
      ProcessBulkUploadDataJob.perform_now(bulk_upload.id, 0, line)
    }.to change { bulk_upload.bulk_upload_errors.count }.by(2)
  end

  it 'logs errors in BulkUploadError model' do
    admin_user = create(:user, role: :admin)
    bulk_upload = BulkUpload.create!(total_lines: 1, user: admin_user)
    line = "U,,Nome,Sobrenome,senha123"

    expect {
      ProcessBulkUploadDataJob.perform_now(bulk_upload.id, 0, line)
    }.to change(BulkUploadError, :count).by(2)

    errors_logs = bulk_upload.bulk_upload_errors
    expect(errors_logs[0].line).to eq(1)
    expect(errors_logs[1].line).to eq(1)
    expect(errors_logs[0].message).to eq "E-mail não pode ficar em branco"
    expect(errors_logs[1].message).to eq "E-mail não é válido"
  end

  it 'increments processed counter in Redis' do
    admin_user = create(:user, role: :admin)
    bulk_upload = BulkUpload.create!(total_lines: 1, user: admin_user)
    redis = Redis.new(url: ENV["REDIS_URL"])

    redis.set("bulk-upload-#{bulk_upload.id}-processed-lines", 0)

    ProcessBulkUploadDataJob.perform_now(bulk_upload.id, 0, "U,usuario@example.com,Nome,Sobrenome,senha123")

    expect(redis.get("bulk-upload-#{bulk_upload.id}-processed-lines").to_i).to eq(1)
  end

  it 'broadcasts turbo stream update' do
    admin_user = create(:user, role: :admin)
    bulk_upload = BulkUpload.create!(total_lines: 1, user: admin_user)
    allow(Turbo::StreamsChannel).to receive(:broadcast_update_to)

    ProcessBulkUploadDataJob.perform_now(bulk_upload.id, 0, "U,usuario@example.com,Nome,Sobrenome,senha123")

    expect(Turbo::StreamsChannel).to have_received(:broadcast_update_to).with(
      "bulk_uploads",
      hash_including(target: "upload_status_#{bulk_upload.id}")
    )
  end

  it 'logs an error for an invalid line format' do
    admin_user = create(:user, role: :admin)
    bulk_upload = BulkUpload.create!(total_lines: 1, user: admin_user)

    invalid_line = "X,invalid,data,format"

    expect {
      ProcessBulkUploadDataJob.perform_now(bulk_upload.id, 0, invalid_line)
    }.to change(BulkUploadError, :count).by(1)

    error_log = BulkUploadError.last
    expect(error_log.bulk_upload_id).to eq(bulk_upload.id)
    expect(error_log.line).to eq(1)
    expect(error_log.message).to eq("Linha inválida")
  end
end
