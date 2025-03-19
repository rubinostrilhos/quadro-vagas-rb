class ProcessFileJob < ApplicationJob
  queue_as :default

  def perform(file_path)
    Rails.logger.info "Iniciando processamento do arquivo: #{file_path}"
    File.foreach(file_path)  do |line|
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
  end

  private

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
    end
  end

  def process_company(row)
    name, website, contact_email, user_id = row[1], row[2], row[3], row[4]
    user = User.find_by(id: user_id)

    if user.nil?
      Rails.logger.error "Usuário com ID #{user_id} não encontrado."
      return
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
    if company.save!
      Rails.logger.info("Empresa #{company.name} criada com sucesso.")
    else
      Rails.logger.info("Erro ao criar empresa: #{company.errors.full_messages.join(', ')}")
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
    if job.save
      Rails.logger.info("Vaga de emprego #{job.title} criada com sucesso.")
    else
      Rails.logger.info("Erro ao criar vaga: #{job.errors.full_messages.join(', ')}")
    end
  end
end
