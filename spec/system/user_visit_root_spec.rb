require 'rails_helper'

describe 'Visitante abre a app', type: :system do
  it 'com sucesso' do
    visit root_path
    expect(page).to have_content 'Olá mundo'
  end

  it 'com sucesso e JavaScript', js: true do
    visit root_path

    expect(page).not_to have_css 'p', text: 'Hello World'
    expect(page).to have_css 'p', text: 'Hello World', wait: 2
  end
end
