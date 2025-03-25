require 'rails_helper'

describe 'User tries to change the status of another user', type: :request do
  context 'as admin' do
    it 'and deactivate with succees' do
      user = create(:user)
      company = create(:company_profile, user: user)
      job_posting = create(:job_posting, company_profile: company)
      admin = create(:user, email_address: 'admin@user.com', role: :admin)

      cookie_jar = ActionDispatch::Request.new(Rails.application.env_config.deep_dup).cookie_jar
      admin.sessions.create!.tap do |session|
        cookie_jar.signed.permanent[:session_id] = { value: session.id, httponly: true, samesite: :lax }
        cookies[:session_id] = cookie_jar[:session_id]
      end

      patch toggle_status_user_path(user)

      user.reload
      company.reload
      job_posting.reload

      expect(user.status).to eq "inactive"
      expect(company.status).to eq "inactive"
      expect(job_posting.status).to eq "archived"
      expect(response).to redirect_to users_path
      expect(response.status).to eq 302
    end

    it 'and cant deactivate another admin' do
      first_admin = create(:user, email_address: 'admin@user.com', role: :admin)
      second_admin = create(:user, email_address: 'second_admin@user.com', role: :admin)

      Current.session = second_admin.sessions.create!
      request = ActionDispatch::Request.new(Rails.application.env_config)
      cookies = request.cookie_jar
      cookies.signed[:session_id] = { value: Current.session.id, httponly: true, same_site: :lax }

      patch toggle_status_user_path(first_admin)

      expect(first_admin.reload.status).to eq "active"
      expect(response).to redirect_to users_path
      expect(response.status).to eq 302
    end

    it 'and activate with succees' do
      user = create(:user, status: :inactive)
      company = create(:company_profile, user: user)
      job_posting = create(:job_posting, company_profile: company)
      admin = create(:user, email_address: 'admin@user.com', role: :admin)

      cookie_jar = ActionDispatch::Request.new(Rails.application.env_config.deep_dup).cookie_jar
      admin.sessions.create!.tap do |session|
        cookie_jar.signed.permanent[:session_id] = { value: session.id, httponly: true, samesite: :lax }
        cookies[:session_id] = cookie_jar[:session_id]
      end

      patch toggle_status_user_path(user)

      expect(user.reload.status).to eq "active"
      expect(company.reload.status).to eq "active"
      expect(job_posting.reload.status).to eq "published"
      expect(response).to redirect_to users_path
      expect(response.status).to eq 302
    end
  end

  context 'as user' do
    it 'and fails because is not admin' do
      user = create(:user)
      second_user = create(:user, email_address: 'second@user.com')

      cookie_jar = ActionDispatch::Request.new(Rails.application.env_config.deep_dup).cookie_jar
      second_user.sessions.create!.tap do |session|
        cookie_jar.signed.permanent[:session_id] = { value: session.id, httponly: true, samesite: :lax }
        cookies[:session_id] = cookie_jar[:session_id]
      end

      patch toggle_status_user_path(user)

      expect(response).to redirect_to root_path
      expect(response.status).to eq 302
    end
  end

  context 'unauthenticated' do
    it 'and fails' do
      user = create(:user)

      patch toggle_status_user_path(user)

      expect(response).to redirect_to new_session_path
      expect(response.status).to eq 302
    end
  end
end
