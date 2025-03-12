require 'rails_helper'

describe 'User sees a list of job postings', type: :system do
  it 'with success' do
    user = create(:user, name: 'João')
    company = create(:company_profile, user: user, name: 'Campus Code')
    create(:job_posting, title: 'Dev Ruby on Rails', company_profile: company)
    create(:job_posting, title: 'Dev Front-End', company_profile: company)

    login_as(user)
    visit root_path
    within('#nav-links') do
      click_on 'Vagas'
    end
    
    expect(page).to have_content('Dev Ruby on Rails')
    expect(page).to have_content('Dev Front-End')
  end

  it 'with an empty list' do
    user = create(:user, name: 'João')

    login_as(user)
    visit root_path
    within('#nav-links') do
      click_on 'Vagas'
    end

    expect(page).to have_content('Ainda não foi criado nenhuma vaga.')
  end

  it 'without logging in' do
    visit root_path
    within('#nav-links') do
      click_on 'Vagas'
    end

    expect(current_path).to eq(new_session_path)
    expect(page).to have_content('Sign in')
    expect(page).to have_content('Forgot password?')
  end

  it 'but don\'t see of the others' do
    user_1 = create(:user, name: 'João', email_address: 'joao@email.com')
    user_2 = create(:user, name: 'Thiago', email_address: 'thiago@email.com')
    company_1 = create(:company_profile, user: user_1, name: 'Campus Code', contact_email: 'contact@campus.com')
    company_2 = create(:company_profile, user: user_2, name: 'Rebase', contact_email: 'contact@rebase.com')
    create(:job_posting, title: 'Dev Ruby on Rails', company_profile: company_1)
    create(:job_posting, title: 'Dev Laravel', company_profile: company_1)
    create(:job_posting, title: 'Dev Front-End', company_profile: company_2)
    create(:job_posting, title: 'Dev Back-End', company_profile: company_2)

    login_as(user_2)
    visit root_path
    within('#nav-links') do
      click_on 'Vagas'
    end

    expect(page).to have_content('Dev Front-End')
    expect(page).to have_content('Dev Back-End')
    expect(page).not_to have_content('Dev Ruby on Rails')
    expect(page).not_to have_content('Dev Laravel')
  end
end