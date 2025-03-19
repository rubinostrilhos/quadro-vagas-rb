class ImportFilesJob < ApplicationJob
  queue_as :default

  def perform(imported_file)
    @imported_file = imported_file
    file_path = ActiveStorage::Blob.service.path_for(imported_file.file.key)
    options = {
                user_provided_headers: [ :col1, :col2, :col3, :col4, :col5, :col6, :col7, :col8, :col9, :col10, :col11 ],
                force_utf8: true
              }
    data = SmarterCSV.process(file_path, options)
    @user_created_count = 0
    @company_profile_created_count = 0
    @job_posting_created_count = 0

    data.each_with_index do |row, i|
      line = i + 1
      row_data = row.values
      row_type = row_data.shift

      case row_type
      when "U"
        register_user(row_data, line)
        imported_file.update(user_created: @user_created_count)
      when "E"
        register_company_profile(row_data, line)
        imported_file.update(company_profile_created: @company_profile_created_count)
      when "V"
        register_job_posting(row_data, line)
        imported_file.update(job_posting_created: @job_posting_created_count)
      else
        error = "Código inválido. Códigos permitidos: U (usuário) / E (empresa) / V (vaga)"
        @imported_file.error_reports.create(errors_list: error, line: line, row_data: row.values.join(","))
      end
      imported_file.update(lines_count: line)
    end
    imported_file.done!
  end

  def register_user(user_data, line)
    email_address, name, last_name = user_data
    password = SecureRandom.alphanumeric(6)
    user = User.new(name: name,
                        last_name: last_name,
                        email_address: email_address,
                        password: password,
                        password_confirmation: password
                      )

    if user.save
      @user_created_count += 1
    else
      error = user.errors.full_messages.join(", ")
      @imported_file.error_reports.create(errors_list: error, line: line, row_data: user_data.join(","))
    end
  end

  def register_company_profile(company_data, line)
    name, website_url, contact_email, user_id = company_data
    company_profile = CompanyProfile.new(name: name,
                                         website_url: website_url,
                                         contact_email: contact_email,
                                         user_id: user_id
                                        )
    company_profile.logo.attach(io: File.open(Rails.root.join("spec/support/files/logo.jpg")), filename: "logo.jpg")
    if company_profile.save
      @company_profile_created_count += 1

    else
      p company_profile.errors.full_messages
      error = company_profile.errors.full_messages.join(", ")
      @imported_file.error_reports.create(errors_list: error, line: line, row_data: company_data.join(","))
    end
  end

  def register_job_posting(job_posting_data, line)
    title, salary, salary_currency, salary_period, work_arrangement, job_type_id, job_location, experience_level_id, company_profile_id, description = job_posting_data
    salary_period, work_arrangement = data_to_symbol(salary_period, work_arrangement)

    job_posting = JobPosting.new(title: title,
                                     salary: salary,
                                     salary_currency: salary_currency.downcase.to_sym,
                                     salary_period: salary_period,
                                     work_arrangement: work_arrangement,
                                     job_type_id: job_type_id,
                                     job_location: job_location,
                                     experience_level_id: experience_level_id,
                                     company_profile_id: company_profile_id,
                                     description: description
                                    )
    if job_posting.save
      @job_posting_created_count += 1

    else
      p job_posting.errors.full_messages
      error = job_posting.errors.full_messages.join(", ")
      @imported_file.error_reports.create(errors_list: error, line: line, row_data: job_posting_data.join(","))
    end
  end

  def data_to_symbol(salary_period, work_arrangement)
    salary_period_dictionary = {
      "Diário" => :daily,
      "Semanalmente" => :weekly,
      "Mensal" => :monthly,
      "Anual" => :yearly
    }

    work_arrangement_dictionary = {
      "Presencial" => :in_person,
      "Remoto" => :remote,
      "Híbrido" => :hybrid
    }

    [ salary_period_dictionary[salary_period], work_arrangement_dictionary[work_arrangement] ]
  end
end
