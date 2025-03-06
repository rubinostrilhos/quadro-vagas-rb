require 'rails_helper'

describe "Visitant vistis home" do
  it "and sees loading page" do
    visit root_path

    expect(page).to have_content 'Carregando...'
  end
end

describe "Visitants visit home, and page loads js", type: :system, js: true do
  it "and then, hello world" do
    visit root_path

    expect(page).to have_content 'Carregando...'

    sleep(3)
    expect(page).to have_content 'Hello, World!'
  end
end
