require 'rails_helper'

describe "Visitor sees job posting", type: :system do
  it "successfully" do
    company = create(:company_profile, name: 'Example')
    job_type = create(:job_type, name: 'Full-time')
    job_posting = create(:job_posting, title: 'Rails', salary: 1000, salary_currency: 'usd',
                         salary_period: 'monthly', company_profile: company, job_type: job_type)

    visit root_path
    click_on 'Rails'

    expect(page).to have_content("Vaga Rails")
    expect(page).to have_content("Empresa: Example")
    expect(page).to have_content("Salário: 10.00 | USD")
    expect(page).to have_content("Período do salário: Mensal")
    expect(page).to have_content("Tipo de trabalho: Full-time")
  end

  it "and goes back to job postings list" do
    node_job_posting = create(:job_posting, title: 'Node')
    second_user = create(:user, email_address: 'second@user.com')
    second_company = create(:company_profile, user: second_user, contact_email: 'second@company.com')
    rails_job_posting = create(:job_posting, company_profile: second_company, title: 'Rails')

    visit root_path
    click_on 'Node'
    click_on "Voltar"

    expect(page).to have_content('Node')
    expect(page).to have_content('Rails')
  end
end
