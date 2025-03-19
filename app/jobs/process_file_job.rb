class ProcessFileJob < ApplicationJob
  queue_as :default

  def perform(file_path)
    total_lines = File.foreach(file_path).count
    processed_lines = 0
    success_count = 0
    errors = []

    File.foreach(file_path) do |line|
      processed_lines += 1
      begin
        process_line(line)
        success_count += 1
      rescue => e
        Rails.logger.error e
        errors << { line: processed_lines, error: e.message, data: line }
      end

      broadcast_progress(processed_lines, total_lines, success_count, errors)
    end
    broadcast_completion(success_count, errors)
  end

  private

  def process_line(line) 
    line = line.strip
    row = line.split(",")
    row = row.map(&:strip)

    case row[0]
    when "U"
      process_user(row)
    when "E"
      process_company(row)
    when "V"
      process_job(row)
    else
      raise StandardError.new( "#{row.inspect}")
    end
  end

  def broadcast_progress(processed_lines, total_lines, success_count, errors)
    Turbo::StreamsChannel.broadcast_replace_to(
      "processing",
      target: "progress-container",
      partial: "processing/progress",
      locals: { processed_lines: processed_lines, total_lines: total_lines, success_count: success_count, errors: errors }
    )
  end

  def broadcast_completion(success_count, errors)
    Turbo::StreamsChannel.broadcast_replace_to(
      "processing",
      target: "progress-container",
      partial: "processing/completion",
      locals: { success_count: success_count, errors: errors }
    )
  end

  def process_user(row)
    email_address, name, last_name = row[1], row[2], row[3]
    password = SecureRandom.alphanumeric(8)
    user = User.new(
      email_address: email_address,
      name: name,
      last_name: last_name,
      password: password,
      password_confirmation: password
    )

    unless user.save
      raise StandardError.new("Erro ao criar usuário: #{user.errors.full_messages.join(', ')}")
    end
  end

  def process_company(row)
    name, website, contact_email, user_id = row[1], row[2], row[3], row[4]
    user = User.find_by(id: user_id)

    if user.nil?
      raise StandardError.new("Usuário com ID #{user_id} não encontrado.")
    end
    company = CompanyProfile.new(
      name: name,
      website_url: website,
      contact_email: contact_email,
      user_id: user.id
    )

    company.logo.attach(
      io: File.open(Rails.root.join("app", "assets", "images", "no-image.png"), "rb"),
      filename: "no-image.png",
      content_type: "image/png"
    )
    unless company.save
      raise StandardError.new("Erro ao criar empresa: #{company.errors.full_messages.join(', ')}")
    end
  end

  def process_job(row)
    title, description, salary, currency, periodicity, work_arrangement, job_type_id, location, experience_level_id, company_id = row[1..9]
    job = JobPosting.new(
      title: title,
      salary: salary.to_f,
      # description: description,
      salary_currency: currency.downcase.to_sym,
      salary_period: periodicity,
      work_arrangement: work_arrangement,
      job_type_id: job_type_id.to_i,
      job_location: location,
      experience_level_id: experience_level_id.to_i,
      company_profile_id: company_id.to_i
    )
    unless job.save
      raise StandardError.new("Erro ao criar vaga: #{job.errors.full_messages.join(', ')}")
    end
  end
end
