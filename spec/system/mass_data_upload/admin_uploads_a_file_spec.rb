require 'rails_helper'

describe 'Admin uploads file', type: :system do
  it 'and must be logged' do
    visit new_files_upload_path

    expect(current_path).to eq new_session_path
 end

  it 'and must be a admin' do
    user = create(:user)
    login_as user

    visit new_files_upload_path

    expect(current_path).to eq new_session_path
  end

  it 'and sees form to upload a file' do
    user = create(:user, role: :admin)
    login_as user

    visit new_files_upload_path

    expect(page).to have_field('file')
    expect(page).to have_button('Enviar')
  end

  it 'and can upload a file, which is processed', js: true do
    user = create(:user, role: :admin)
    login_as user

    file_path = Rails.root.join('spec', 'support', 'files', 'test_file.csv')

    visit new_files_upload_path
    attach_file('file', file_path)
    click_button 'Enviar'
    sleep(2)

    expect(ProcessFileJob).to have_been_enqueued
    expect(page).to have_content "Arquivo enviado com sucesso. Processando arquivo..."
  end
end
