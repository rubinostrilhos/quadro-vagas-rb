require 'rails_helper'

RSpec.describe ImportFilesJob, type: :job do
  include ActiveSupport::Testing::TimeHelpers
  it 'A fila de jobs é gerada com sucesso' do
    admin = build(:user)
    admin.admin!

    imported_file = admin.imported_files.build(file_name: 'Arquivo txt')
    imported_file.file.attach(Rails.root.join('spec/fixtures/desafio_2.txt'))
    imported_file.save!

    ImportFilesJob.perform_later(imported_file)

    expect(enqueued_jobs.size).to eq(1)
  end

  it 'deve gerar models através do arquivo txt' do
    user = create(:user, id: 1)
    second_user = create(:user, id: 2)
    third_user = create(:user, id: 3)
    admin = create(:user, role: :admin, id: 4)
    company = create(:company_profile, id: 2, user: admin)
    second_company = create(:company_profile, id: 3, user: third_user)
    create(:job_type, name: 'Part Time', id: 1)
    create(:experience_level, name: 'Junior', id: 1)
    create(:experience_level, name: 'Senior', id: 2)
    imported_file = admin.imported_files.build(file_name: 'Arquivo txt')
    imported_file.file.attach(Rails.root.join('spec/fixtures/desafio_2.txt'))
    imported_file.save!

    ImportFilesJob.perform_now(imported_file)

    expect(User.count).to eq 6
    expect(CompanyProfile.count).to eq 4
    expect(JobPosting.count).to eq 2
    expect(user.company_profile.name).to eq 'Empresa A'
    expect(second_user.company_profile.name).to eq 'Empresa B'
    expect(company.job_postings.first.title).to eq 'Desenvolvedor Frontend'
    expect(second_company.job_postings.first.title).to eq 'Desenvolvedor Ruby on Rails'
  end

  it 'deve gerar models através do arquivo csv' do
    user = create(:user, id: 1)
    second_user = create(:user, id: 2)
    third_user = create(:user, id: 3)
    admin = create(:user, role: :admin, id: 4)
    company = create(:company_profile, id: 2, user: admin)
    second_company = create(:company_profile, id: 3, user: third_user)
    create(:job_type, name: 'Part Time', id: 1)
    create(:experience_level, name: 'Junior', id: 1)
    create(:experience_level, name: 'Senior', id: 2)
    imported_file = admin.imported_files.build(file_name: 'Arquivo txt')
    imported_file.file.attach(Rails.root.join('spec/fixtures/desafio_2.csv'))
    imported_file.save!

    ImportFilesJob.perform_now(imported_file)

    expect(User.count).to eq 6
    expect(CompanyProfile.count).to eq 4
    expect(JobPosting.count).to eq 2
    expect(user.company_profile.name).to eq 'Empresa A'
    expect(second_user.company_profile.name).to eq 'Empresa B'
    expect(company.job_postings.first.title).to eq 'Desenvolvedor Frontend'
    expect(second_company.job_postings.first.title).to eq 'Desenvolvedor Ruby on Rails'
  end

  it 'deve gerar os erros corretamente' do
    user = create(:user, id: 1)
    second_user = create(:user, id: 2)
    third_user = create(:user, id: 3)
    admin = create(:user, role: :admin, id: 4)
    company = create(:company_profile, id: 2, user: admin)
    second_company = create(:company_profile, id: 3, user: third_user)
    create(:job_type, name: 'Part Time', id: 1)
    create(:experience_level, name: 'Junior', id: 1)
    create(:experience_level, name: 'Senior', id: 2)
    imported_file = admin.imported_files.build(file_name: 'Arquivo txt')
    imported_file.file.attach(Rails.root.join('spec/fixtures/broken_file.txt'))
    imported_file.save!

    ImportFilesJob.perform_now(imported_file)

    expect(User.count).to eq 5
    expect(CompanyProfile.count).to eq 3
    expect(JobPosting.count).to eq 1
    p imported_file.error_report.error_message
    expect(imported_file.error_report.error_message).to include "A linha 2 é inválida;Erros: E-mail não é válido"
    expect(imported_file.error_report.error_message).to include "A linha 3 é inválida;Erros: URL do Site deve ser um URL válido (começar com http:// ou https://, ter ponto separando o domínio e terminar com uma extensão válida de 2 a 6 caracteres)"
    expect(imported_file.error_report.error_message).to include "A linha 6 é inválida;Erros: Período do salário não pode ficar em branco"
    expect(imported_file.error_report.error_message).to include "O código passado na linha 7 é inválido. Códigos permitidos: U (usuário) / E (empresa) / V (vaga)"
  end
end
