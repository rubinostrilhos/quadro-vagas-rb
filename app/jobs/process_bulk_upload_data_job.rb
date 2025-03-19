class ProcessBulkUploadDataJob < ApplicationJob
  queue_as :default

  def perform(bulk_upload_id, index, line)
    return if line.blank?

    type, *data = line.strip.split(",")

    bulk_upload = BulkUpload.find_by(id: bulk_upload_id)

    case type
    when "U"
      create_user(bulk_upload_id, data, (index + 1))
    when "E"
      create_company(bulk_upload_id, data, (index + 1))
    when "V"
      create_job(bulk_upload_id, data, (index + 1))
    else
      add_error_log(bulk_upload_id, (index + 1), "Linha inválida")
    end

    redis.incr("bulk-upload-#{bulk_upload_id}-processed-lines")
    redis.decr("bulk-upload-#{bulk_upload_id}-remaining-lines")

    bulk_upload.update(status: 20, errors_count: redis.get("bulk-upload-#{bulk_upload_id}-errors-count").to_i)

    Turbo::StreamsChannel.broadcast_update_to(
      "bulk_uploads",
      target: "upload_status_#{bulk_upload_id}",
      partial: "bulk_uploads/status_details",
      locals: {
        processed: redis.get("bulk-upload-#{bulk_upload_id}-processed-lines").to_i,
        remaining: redis.get("bulk-upload-#{bulk_upload_id}-remaining-lines").to_i,
        successful: redis.get("bulk-upload-#{bulk_upload_id}-successful").to_i,
        errors: redis.get("bulk-upload-#{bulk_upload_id}-errors-count").to_i,
        errors_details: JSON.parse(redis.get("bulk-upload-#{bulk_upload_id}-errors-details") || "[]").sort_by! { |msg| msg.match(/Linha (\d+)/)&.captures&.first.to_i },
        total_lines: bulk_upload.total_lines
      }
    )

  rescue => e
    puts "Error processing line: #{(index + 1)} - #{e.message}"
  end

  private

  def create_user(bulk_upload_id, data, line_number)
    email_address, name, last_name  = data
    password = SecureRandom.hex(8)

    user = User.new(name: name, last_name: last_name, email_address: email_address, password: password, password_confirmation: password)

    if user.valid?
      redis.incr("bulk-upload-#{bulk_upload_id}-successful") if user.save
    else
      user.errors.full_messages.each do |error|
        add_error_log(bulk_upload_id, line_number, error)
      end
    redis.incr("bulk-upload-#{bulk_upload_id}-errors-count")
    end
  end

  def create_company(bulk_upload_id, data, line_number)
    name, website_url, contact_email, user_id = data

    company = CompanyProfile.new(name: name, website_url: website_url, contact_email: contact_email, user_id: user_id)
    company.logo.attach(io: File.open(Rails.root.join("spec/support/files/logo.jpg")), filename: "logo.jpg")

    if company.valid?
      redis.incr("bulk-upload-#{bulk_upload_id}-successful") if company.save
    else
      company.errors.full_messages.each do |error|
        add_error_log(bulk_upload_id, line_number, error)
      end
    redis.incr("bulk-upload-#{bulk_upload_id}-errors-count")
    end
  end

  def create_job(bulk_upload_id, data, line_number)
    title, description, salary, salary_currency, salary_period, work_arrangement, job_type_id, job_location, experience_level_id, company_id = data

    formated_salary_period = nil
    formated_work_arrangement = nil

    case salary_period
    when "Mensal"
      formated_salary_period = 20
    when "Anual"
      formated_salary_period = 30
    when "Semanal"
      formated_salary_period = 10
    when "Diário"
      formated_salary_period = 0
    end

    case work_arrangement
    when "Presencial"
      formated_work_arrangement = 20
    when "Remoto"
      formated_work_arrangement = 0
    when "Híbrido"
      formated_work_arrangement = 10
    end

    job = JobPosting.new(title: title, description: description, salary: salary, salary_currency: salary_currency, salary_period: formated_salary_period, work_arrangement: formated_work_arrangement, job_type_id: job_type_id, job_location: job_location, experience_level_id: experience_level_id, company_profile_id: company_id)

    if job.valid?
      redis.incr("bulk-upload-#{bulk_upload_id}-successful") if job.save
    else
      job.errors.full_messages.each do |error|
        add_error_log(bulk_upload_id, line_number, error)
      end
    redis.incr("bulk-upload-#{bulk_upload_id}-errors-count")
    end
  end

  def add_error_log(bulk_upload_id, line_number, error)
    errors_details = JSON.parse(redis.get("bulk-upload-#{bulk_upload_id}-errors-details") || "[]")
    errors_details.push("Linha #{line_number}: #{error}")
    redis.set("bulk-upload-#{bulk_upload_id}-errors-details", errors_details.to_json)
  end

  def redis
    @redis ||= Redis.new(url: ENV["REDIS_URL"])
  end
end
