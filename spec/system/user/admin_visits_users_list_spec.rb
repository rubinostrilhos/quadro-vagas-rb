require 'rails_helper'

describe 'User visits users list', type: :system do
  context 'as admin' do
    it 'and sees active and inactive users' do
      active_user = create(:user, email_address: 'active@user.com', status: :active)
      inactive_user = create(:user, email_address: 'inactive@user.com', status: :inactive)
      admin = create(:user, email_address: 'admin@user.com', role: :admin)

      Current.session = admin.sessions.create!
      request = ActionDispatch::Request.new(Rails.application.env_config)
      cookies = request.cookie_jar
      cookies.signed[:session_id] = { value: Current.session.id, httponly: true, same_site: :lax }

      visit root_path
      click_on 'Usuários'

      expect(page).to have_content active_user.email_address
      expect(page).to have_content active_user.name
      expect(page).to have_content inactive_user.email_address
      expect(page).to have_content inactive_user.name
      expect(page).to have_content admin.email_address
      expect(page).to have_content admin.name
    end

    it 'and deactivate with succees' do
      user = create(:user)
      company = create(:company_profile, user: user)
      job_posting = create(:job_posting, company_profile: company)
      admin = create(:user, email_address: 'admin@user.com', role: :admin)

      Current.session = admin.sessions.create!
      request = ActionDispatch::Request.new(Rails.application.env_config)
      cookies = request.cookie_jar
      cookies.signed[:session_id] = { value: Current.session.id, httponly: true, same_site: :lax }

      visit root_path
      click_on 'Usuários'

      within find("tr", text: user.email_address) do
        click_on 'Desativar usuário'
      end

      expect(user.reload.status).to eq "inactive"
      expect(company.reload.status).to eq "inactive"
      expect(job_posting.reload.status).to eq "inactive"
      expect(page).to have_css("td.text-red-500", text: User.human_enum_name('status', user.reload.status))
      expect(page).to have_content 'Status alterado com sucesso.'
    end

    it 'and cant deactivate another admin' do
      first_admin = create(:user, email_address: 'admin@user.com', role: :admin)
      second_admin = create(:user, email_address: 'second_admin@user.com', role: :admin)

      Current.session = first_admin.sessions.create!
      request = ActionDispatch::Request.new(Rails.application.env_config)
      cookies = request.cookie_jar
      cookies.signed[:session_id] = { value: Current.session.id, httponly: true, same_site: :lax }

      visit root_path
      click_on 'Usuários'

      within find("tr", text: second_admin.email_address) do
        click_on 'Desativar usuário'
      end

      expect(second_admin.reload.status).to eq "active"
      expect(page).to have_content 'Não é possível alterar o status de um administrador.'
    end

    it 'and activate with succees' do
      user = create(:user, status: :inactive)
      company = create(:company_profile, user: user)
      job_posting = create(:job_posting, company_profile: company)
      admin = create(:user, email_address: 'admin@user.com', role: :admin)

      Current.session = admin.sessions.create!
      request = ActionDispatch::Request.new(Rails.application.env_config)
      cookies = request.cookie_jar
      cookies.signed[:session_id] = { value: Current.session.id, httponly: true, same_site: :lax }

      visit root_path
      click_on 'Usuários'

      within find("tr", text: user.email_address) do
        click_on 'Ativar usuário'
      end

      expect(user.reload.status).to eq "active"
      expect(company.reload.status).to eq "active"
      expect(job_posting.reload.status).to eq "active"
      expect(page).to have_css("td.text-green-500", text: User.human_enum_name('status', user.reload.status))
      expect(page).to have_content 'Status alterado com sucesso.'
    end
  end

  context 'as user' do
    it 'and fails because is not admin' do
      user = create(:user)

      Current.session = user.sessions.create!
      request = ActionDispatch::Request.new(Rails.application.env_config)
      cookies = request.cookie_jar
      cookies.signed[:session_id] = { value: Current.session.id, httponly: true, same_site: :lax }

      visit users_path

      expect(page).not_to have_button 'Desativar'
      expect(page).not_to have_button 'Ativar'
      expect(current_path).to eq root_path
      expect(page).to have_content 'Acesso não autorizado'
    end

    it 'and cant access unauthenticated' do
      visit users_path

      expect(current_path).to eq new_session_path
    end
  end
end
