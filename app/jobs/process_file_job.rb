class ProcessFileJob < ApplicationJob
  queue_as :default

  def perform(file_path)
    Rails.logger.info("Início")
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
    Rails.logger.info("Processando Linha")
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
      Rails.logger.error "Linha inválida: #{row.inspect}"
    end
  end

  def broadcast_progress(processed_lines, total_lines, success_count, errors)
    Rails.logger.info("Broadcast Progress")
    Turbo::StreamsChannel.broadcast_replace_to(
      "processing",
      target: "progress-container",
      partial: "processing/progress",
      locals: { processed_lines: processed_lines, total_lines: total_lines, success_count: success_count, errors: errors }
    )
  end

  def broadcast_completion(success_count, errors)
    Rails.logger.info("Broadcast Completion")
    Turbo::StreamsChannel.broadcast_replace_to(
      "processing",
      target: "progress-container",
      partial: "processing/completion",
      locals: { success_count: success_count, errors: errors }
    )
  end

  def process_user(row)
    email_address, name, last_name = row[1], row[2], row[3]
    Rails.logger.info "Processando usuário: #{email_address}"

    password = SecureRandom.alphanumeric(8)
    user = User.new(
      email_address: email_address,
      name: name,
      last_name: last_name,
      password: password,
      password_confirmation: password
    )

    if user.save
      Rails.logger.info "Usuário #{user.email_address} criado com sucesso."
    else
      Rails.logger.error "Erro ao criar usuário: #{user.errors.full_messages.join(', ')}"
      raise StandardError.new("Erro ao criar usuário: #{user.errors.full_messages.join(', ')}")
    end
  end

  def process_company(row)
    name, website, contact_email, user_id = row[1], row[2], row[3], row[4]
    user = User.find_by(id: user_id)

    if user.nil?
      Rails.logger.error "Usuário com ID #{user_id} não encontrado."
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

    if company.save
      Rails.logger.info("Empresa #{company.name} criada com sucesso.")
    else
      Rails.logger.error("Erro ao criar empresa: #{company.errors.full_messages.join(', ')}")
      raise StandardError.new("Erro ao criar empresa: #{company.errors.full_messages.join(', ')}")
    end
  end

  def process_job(row)
    title, description, salary, currency, periodicity, work_arrangement, job_type_id, location, experience_level_id, company_id = row[1..9]
    job = JobPosting.new(
      title: title,
      salary: salary.to_f,
      salary_currency: currency.downcase.to_sym,
      salary_period: periodicity,
      work_arrangement: work_arrangement,
      job_type_id: job_type_id.to_i,
      job_location: location,
      experience_level_id: experience_level_id.to_i,
      company_profile_id: company_id.to_i
    )

    if job.save
      Rails.logger.info("Vaga de emprego #{job.title} criada com sucesso.")
    else
      Rails.logger.error("Erro ao criar vaga: #{job.errors.full_messages.join(', ')}")
      raise StandardError.new("Erro ao criar vaga: #{job.errors.full_messages.join(', ')}")
    end
  end
end
