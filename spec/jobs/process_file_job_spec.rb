require 'rails_helper'

RSpec.describe ProcessFileJob, type: :job do
  it 'creates user from a file' do
    file_path = Rails.root.join('spec', 'support', 'files', 'test_file.csv')
    File.open(file_path, 'w') do |file|
      file.puts "U,joao@email.com, Joao, Almeida"
      file.puts "U,erika@email.com, Erika, Campos"
      file.puts "U,otavio@email.com, Otavio, Lins"
    end

    expect {
      ProcessFileJob.perform_now(file_path)
    }.to change(User, :count).by(3)

    expect(User.last.name). to eq "Otavio"
  end

  it 'creates company from a file' do
    user_1 = create(:user)
    user_2 = create(:user, email_address: "erika@email.com")
    file_path = Rails.root.join('spec', 'support', 'files', 'test_file.csv')
    File.open(file_path, 'w') do |file|
      file.puts "E,Empresa A,https://www.empresa-a.com,contato@empresa-a.com,#{user_1.id}"
      file.puts "E,Empresa B,https://www.empresa-b.com,contato@empresa-b.com,#{user_2.id}"
    end

    expect {
      ProcessFileJob.perform_now(file_path)
    }.to change(CompanyProfile, :count).by(2)

    last_company = CompanyProfile.last

    expect(last_company.name). to eq "Empresa B"
    expect(last_company.website_url). to eq "https://www.empresa-b.com"
    expect(last_company.contact_email). to eq "contato@empresa-b.com"
    expect(last_company.user_id). to eq user_2.id
  end
end
