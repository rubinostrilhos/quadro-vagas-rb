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
    redis.set("bulk-upload-#{bulk_upload.id}-remaining-lines", 1)
    redis.set("bulk-upload-#{bulk_upload.id}-successful", 0)
    redis.set("bulk-upload-#{bulk_upload.id}-errors-count", 0)

    ProcessBulkUploadDataJob.perform_now(bulk_upload.id, 0, line)

    expect(redis.get("bulk-upload-#{bulk_upload.id}-processed-lines").to_i).to eq(1)
    expect(redis.get("bulk-upload-#{bulk_upload.id}-remaining-lines").to_i).to eq(0)
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
end
