require 'rails_helper'

describe 'Admin changes experience level status', type: :system do
  it 'sucefuly', js: true  do
    user = create(:user, role: :admin)
    Current.session = user.sessions.create!
    request = ActionDispatch::Request.new(Rails.application.env_config)
    cookies = request.cookie_jar
    cookies.signed[:session_id] = { value: Current.session.id, httponly: true, same_site: :lax }

    ExperienceLevel.create(
      name: "Junior",
      status: :archived
    )

    visit experience_levels_path
    click_on "Ativar"

    expect(page).to have_content 'Junior'
    expect(page).to have_content 'Status: Ativo'
  end
end
