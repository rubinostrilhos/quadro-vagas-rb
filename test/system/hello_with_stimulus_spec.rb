require "rails_helper"

describe "Usuário vê hello world", type: :system, js: true do
  it "com sucesso" do
    visit root_path

    expect(page).to have_content "hello world!"
  end
end
