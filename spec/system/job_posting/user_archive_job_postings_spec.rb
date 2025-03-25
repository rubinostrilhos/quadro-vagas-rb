require 'rails_helper'

describe "User archive a job posting", type: :system do
  it "successfuly" do
    experience_level_jr = ExperienceLevel.create(name: "Junior")
    first_user = create(:user, email_address: 'first@email.com')
    first_company = create(:company_profile, user: first_user, contact_email: 'first@company.com')
    rails_job = create(:job_posting, title: "Ruby on Rails Dev Jr.", status: :published, company_profile: first_company, experience_level: experience_level_jr)
    second_user = create(:user, email_address: 'second@email.com')
    second_company = create(:company_profile, user: second_user, contact_email: 'second@company.com')
    django_job = create(:job_posting, title: "Django Dev Jr.", status: :published, company_profile: second_company, experience_level: experience_level_jr)

    login_as second_user
    visit root_path
    click_link 'Django Dev Jr.'
    click_button 'Arquivar'

    job = JobPosting.last
    expect(job.status).to eq 'archived'
    expect(page).to have_content "Anúncio arquivado com sucesso"
    expect(page).to have_button "Republicar"
    expect(page).not_to have_button "Arquivar"
  end

  it "and is not the owner" do
    experience_level_jr = ExperienceLevel.create(name: "Junior")
    first_user = create(:user, email_address: 'first@email.com')
    first_company = create(:company_profile, user: first_user, contact_email: 'first@company.com')
    rails_job = create(:job_posting, title: "Ruby on Rails Dev Jr.", status: :published, company_profile: first_company, experience_level: experience_level_jr)
    second_user = create(:user, email_address: 'second@email.com')
    second_company = create(:company_profile, user: second_user, contact_email: 'second@company.com')
    django_job = create(:job_posting, title: "Django Dev Jr.", status: :published, company_profile: second_company, experience_level: experience_level_jr)

    login_as second_user
    visit root_path
    click_link 'Ruby on Rails Dev Jr.'

    expect(page).not_to have_button "Arquivar"
    expect(page).not_to have_button "Republicar"
  end

  it "and post again" do
    first_user = create(:user, email_address: 'first@email.com')
    first_company = create(:company_profile, user: first_user, contact_email: 'first@company.com')
    rails_job = create(:job_posting, title: "Ruby on Rails Dev Jr.", status: :archived, company_profile: first_company)

    login_as first_user
    visit root_path
    click_link 'Ruby on Rails Dev Jr.'
    click_button 'Republicar'

    job = JobPosting.last
    expect(job.status).to eq 'published'
    expect(page).to have_content "Anúncio publicado com sucesso"
    expect(page).to have_button "Arquivar"
    expect(page).not_to have_button "Republicar"
  end

  it "shows error message when archiving fails" do
    user = create(:user, email_address: 'user@email.com')
    company = create(:company_profile, user: user, contact_email: 'user@company.com')
    job = create(:job_posting, title: "Test Job", status: :published, company_profile: company)
    allow_any_instance_of(JobPosting).to receive(:archived!).and_return(false)

    login_as user
    visit root_path
    click_link 'Test Job'
    click_button 'Arquivar'

    expect(page).to have_content "Erro ao tentar arquivar anúncio da vaga"
    expect(job.reload.status).not_to eq 'archived'
  end

  it "shows error message when posting fails" do
    user = create(:user, email_address: 'user@email.com')
    company = create(:company_profile, user: user, contact_email: 'user@company.com')
    job = create(:job_posting, title: "Test Job", status: :archived, company_profile: company)
    allow_any_instance_of(JobPosting).to receive(:published!).and_return(false)

    login_as user
    visit root_path
    click_link 'Test Job'
    click_button 'Republicar'

    expect(page).to have_content "Erro ao tentar publicar anúncio da vaga"
    expect(job.reload.status).not_to eq 'published'
  end
end
