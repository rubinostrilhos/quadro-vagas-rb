require 'rails_helper'

describe "User see job postings", type: :system do
  it "that are published and archived", js: true do
    experience_level_jr = ExperienceLevel.create(name: "Junior")
    first_user = create(:user, email_address: 'first@email.com')
    first_company = create(:company_profile, user: first_user, contact_email: 'first@company.com')
    rails_job = create(:job_posting, title: "Ruby on Rails Dev Jr.", status: :published, company_profile: first_company, experience_level: experience_level_jr)
    node_job = create(:job_posting, title: "Node Dev Jr.", status: :archived, company_profile: first_company, experience_level: experience_level_jr)
    second_user = create(:user, email_address: 'second@email.com')
    second_company = create(:company_profile, user: second_user, contact_email: 'second@company.com')
    django_job = create(:job_posting, title: "Django Dev Jr.", status: :published, company_profile: second_company, experience_level: experience_level_jr)

    login_as first_user
    visit root_path

    expect(page).to have_content rails_job.title
    expect(page).to have_selector("#job_posting_#{node_job.id}")
    within("#job_posting_#{node_job.id}") do
      expect(page).to have_content node_job.title
      expect(page).to have_content 'Arquivado'
    end
    expect(page).to have_content django_job.title
  end
end
