require 'rails_helper'

describe "Visitor sees job posting", type: :system do
  it "successfully" do
    job_posting = create(:job_posting)

    visit root_path
    click_on job_posting.title

    expect(page).to have_content("Details for: #{job_posting.title}")
    expect(page).to have_content("Company: #{job_posting.company_profile.name}")
    expect(page).to have_content("Salary: #{job_posting.salary} | #{job_posting.salary_currency}")
    expect(page).to have_content("Salary Period: #{job_posting.salary_period}")
    expect(page).to have_content("Job Type: #{job_posting.job_type.name}")
  end

  it "and goes back to job postings list" do
    node_job_posting = create(:job_posting, title: 'Dev Node')
    second_user = create(:user, email_address: 'second@user.com')
    second_company = create(:company_profile, name: 'Empresa Dev', user: second_user, contact_email: 'second@company.com')
    rails_job_posting = create(:job_posting, company_profile: second_company)

    visit root_path
    click_on node_job_posting.title
    click_on "Back"

    expect(page).to have_content(node_job_posting.title)
    expect(page).to have_content(rails_job_posting.title)
  end
end
