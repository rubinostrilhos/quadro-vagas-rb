require 'rails_helper'

describe "Visitor sees job posting", type: :system do
  it "successfully" do
    job_type = create(:job_type, name: 'Júnior')
    company = create(:company_profile, name: 'Empresa')
    job_posting = create(:job_posting, title: 'Dev React',
                         salary: 1000,
                         salary_currency: :brl,
                         salary_period: :monthly,
                         job_type: job_type,
                         company_profile: company)

    visit root_path
    click_on job_posting.title

    expect(page).to have_content("Dev React")
    expect(page).to have_content("Empresa: Empresa")
    expect(page).to have_content("Salário: 10.00 | BRL")
    expect(page).to have_content("Período do salário: Mensal")
    expect(page).to have_content("Tipo de trabalho: Júnior")
  end

  it "and goes back to job postings list" do
    node_job_posting = create(:job_posting)

    visit root_path
    click_on node_job_posting.title
    click_on "Voltar"

    expect(page).to have_content(node_job_posting.title)
    expect(current_path).to eq root_path
  end

  it 'and fails because job posting is inactive' do
    user = create(:user, status: :inactive)
    company = create(:company_profile, user: user)
    job_posting = create(:job_posting, company_profile: company)

    visit job_posting_path(job_posting)

    expect(current_path).to eq root_path
  end

  it 'and can see inactive job postings because is admin' do
    user = create(:user, status: :inactive)
    job_type = create(:job_type, name: 'Júnior')
    company = create(:company_profile, name: 'Empresa')
    job_posting = create(:job_posting, title: 'Dev React',
                         salary: 1000,
                         salary_currency: :brl,
                         salary_period: :monthly,
                         job_type: job_type,
                         company_profile: company)
    admin = create(:user, email_address: 'admin@user.com', role: :admin)

    Current.session = admin.sessions.create!
    request = ActionDispatch::Request.new(Rails.application.env_config)
    cookies = request.cookie_jar
    cookies.signed[:session_id] = { value: Current.session.id, httponly: true, same_site: :lax }

    visit job_posting_path(job_posting)

    expect(current_path).to eq job_posting_path(job_posting)
    expect(page).to have_content("Empresa: Empresa")
    expect(page).to have_content("Salário: 10.00 | BRL")
    expect(page).to have_content("Período do salário: Mensal")
    expect(page).to have_content("Tipo de trabalho: Júnior")
  end
end
