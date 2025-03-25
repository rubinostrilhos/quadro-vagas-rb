require 'rails_helper'

describe 'User tries to archive a job posting', type: :request do
  it 'and fails for not being authenticated' do
    post(archive_job_posting_path(id: 1))

    expect(response).to redirect_to new_session_path
    expect(response.status).to eq 302
  end

  it 'and repost fails for not being authenticated' do
    post(post_job_posting_path(id: 1))

    expect(response).to redirect_to new_session_path
    expect(response.status).to eq 302
  end

  it 'and fails because user is not the owner' do
    experience_level_jr = ExperienceLevel.create(name: "Junior")
    first_user = create(:user, email_address: 'first@email.com')
    first_company = create(:company_profile, user: first_user, contact_email: 'first@company.com')
    rails_job = create(:job_posting, title: "Ruby on Rails Dev Jr.", status: :published, company_profile: first_company, experience_level: experience_level_jr)
    second_user = create(:user, email_address: 'second@email.com')
    second_company = create(:company_profile, user: second_user, contact_email: 'second@company.com')
    django_job = create(:job_posting, title: "Django Dev Jr.", status: :published, company_profile: second_company, experience_level: experience_level_jr)

    post session_path params: { password: first_user.password, email_address: first_user.email_address }
    post(archive_job_posting_path(django_job))

    expect(django_job.archived?).to be false
    expect(django_job.published?).to be true
    expect(flash[:alert]).to eq 'Acesso não autorizado'
    expect(response).to redirect_to job_posting_path(django_job)
    expect(response.status).to eq 302
  end

  it 'and repost when user is not the owner' do
    experience_level_jr = ExperienceLevel.create(name: "Junior")
    first_user = create(:user, email_address: 'first@email.com')
    first_company = create(:company_profile, user: first_user, contact_email: 'first@company.com')
    rails_job = create(:job_posting, title: "Ruby on Rails Dev Jr.", status: :archived, company_profile: first_company, experience_level: experience_level_jr)
    second_user = create(:user, email_address: 'second@email.com')
    second_company = create(:company_profile, user: second_user, contact_email: 'second@company.com')
    django_job = create(:job_posting, title: "Django Dev Jr.", status: :archived, company_profile: second_company, experience_level: experience_level_jr)

    post session_path params: { password: first_user.password, email_address: first_user.email_address }
    post(post_job_posting_path(django_job))

    expect(django_job.archived?).to be true
    expect(django_job.published?).to be false
    expect(flash[:alert]).to eq 'Acesso não autorizado'
    expect(response).to redirect_to job_posting_path(django_job)
    expect(response.status).to eq 302
  end
end
