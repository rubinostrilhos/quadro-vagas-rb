require 'rails_helper'

describe 'User create experience level', type: :request  do
  it 'and must be logged in' do
    post(experience_levels_path, params: { experience_level: { name: 'Junior', status: :archived } })

    expect(response).to redirect_to(new_session_path)
  end

  it 'and user must be admin' do
    user = create(:user, role: :regular)
    login_as user

    post(experience_levels_path, params: { experience_level: { name: 'Junior', status: :archived } })

    expect(response).to redirect_to(root_path)
  end

  it 'succesfully' do
    user = create(:user, role: :admin)
    login_as user

    post(experience_levels_path, params: { experience_level: { name: 'Junior', status: :archived } })

    expect(response).to redirect_to(experience_levels_path)
  end

  it 'and fails when name is empty' do
    user = create(:user, role: :admin)
    login_as user

    post(experience_levels_path, params: { experience_level: { status: :archived } })

    expect(response).to have_http_status(:unprocessable_entity)
  end

  it 'and fails when name is repated' do
    user = create(:user, role: :admin)
    login_as user

    create(:experience_level, name: 'Junior')
    post(experience_levels_path, params: { experience_level: { name: 'Junior', status: :archived } })

    expect(response).to have_http_status(:unprocessable_entity)
  end
end
