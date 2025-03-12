require 'rails_helper'

describe "Visitor sees job posting", type: :system do
  it "successfully" do
    job_posting = create(:job_posting)

    visit root_path
    click_on job_posting.title

    expect(page).to have_content("Detalhes de: #{job_posting.title}")
    expect(page).to have_content("Empresa: #{job_posting.company_profile.name}")
    expect(page).to have_content("Salário: #{job_posting.salary} | #{job_posting.salary_currency}")
    expect(page).to have_content("Pagamento: #{job_posting.salary_period}")
    expect(page).to have_content("Tipo de Trabalho: #{job_posting.job_type.name}")
  end

  it "and goes back to job postings list" do
    node_job_posting = create(:job_posting)
    second_user = create(:user, email_address: 'second@user.com')
    second_company = create(:company_profile, user: second_user, contact_email: 'second@company.com')
    rails_job_posting = create(:job_posting, company_profile: second_company)

    visit root_path
    click_on node_job_posting.title
    click_on "Voltar"

    expect(page).to have_content(node_job_posting.title)
    expect(page).to have_content(rails_job_posting.title)
  end
end
