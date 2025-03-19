require 'rails_helper'

describe 'Registered user tries to access the page to see their company profile', type: :system do
  it 'and succeeds', js: true do
    user = create(:user)
    logo = Rack::Test::UploadedFile.new(Rails.root.join('spec', 'support', 'files', 'logo.png'), 'image/png')
    company_profile = create(
      :company_profile,
      name: 'BlinkedOn',
      website_url: 'https://blinkedon.tech',
      contact_email: 'contact@blinkedon.tech',
      logo:  logo,
      user: user
    )

    Current.session = user.sessions.create!
    request = ActionDispatch::Request.new(Rails.application.env_config)
    cookies = request.cookie_jar
    cookies.signed[:session_id] = { value: Current.session.id, httponly: true, same_site: :lax }

    visit root_path

    click_on 'Perfil da Empresa'

    expect(current_path).to eq company_profile_path(company_profile)
    expect(page).to have_content 'Perfil da minha Empresa'
    expect(page).to have_content "Nome: BlinkedOn"
    expect(page).to have_content "Email de Contato: contact@blinkedon.tech"
    expect(page).to have_content "URL do Site: https://blinkedon.tech"
    expect(page).to have_css('img[src*="logo.png"]')
  end
end
