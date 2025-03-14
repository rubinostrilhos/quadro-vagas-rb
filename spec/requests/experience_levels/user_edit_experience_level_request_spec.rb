require 'rails_helper'

describe 'User edits experience level', type: :request do
  it 'and must be logged in' do
    experience_level = ExperienceLevel.create(
      name: "Junior",
      status: :archived
    )
    patch(experience_level_path(experience_level.id), params: { experience_level: { name: 'Junior', status: :archived } })

    expect(response).to redirect_to(new_session_path)
  end

  it 'and user must be admin' do
    user = create(:user, role: :regular)
    login_as user
    experience_level = ExperienceLevel.create(
      name: "Junior",
      status: :archived
    )

    patch(experience_level_path(experience_level.id), params: { experience_level: { name: 'Pleno', status: :archived } })

    expect(response).to redirect_to(root_path)
  end

  it 'succesfully' do
    user = create(:user, role: :admin)
    login_as user
    experience_level = ExperienceLevel.create(
      name: "Junior",
      status: :archived
    )

    patch(experience_level_path(experience_level.id), params: { experience_level: { name: 'Pleno', status: :archived } })

    expect(response).to redirect_to(experience_levels_path)
  end

  it 'fail when name is empty' do
    user = create(:user, role: :admin)
    login_as user
    experience_level = ExperienceLevel.create(
      name: "Junior",
      status: :archived
    )

    patch(experience_level_path(experience_level.id), params: { experience_level: { name: nil, status: :archived } })

    expect(response).to have_http_status(:unprocessable_entity)
  end

  it 'fail when name is repeated' do
    user = create(:user, role: :admin)
    login_as user
    experience_level = ExperienceLevel.create(
      name: "Junior",
      status: :archived
    )
    experience_level_second = ExperienceLevel.create(
      name: "Pleno",
      status: :archived
    )

    patch(experience_level_path(experience_level.id), params: { experience_level: { name: 'Pleno', status: :archived } })

    expect(response).to have_http_status(:unprocessable_entity)
  end
end
