require 'rails_helper'

describe 'User visits upload bulk data page', type: :system do
  it 'and fails because is not admin' do
    user = create(:user)

    Current.session = user.sessions.create!
    request = ActionDispatch::Request.new(Rails.application.env_config)
    cookies = request.cookie_jar
    cookies.signed[:session_id] = { value: Current.session.id, httponly: true, same_site: :lax }

    visit new_bulk_upload_path

    expect(current_path).to eq root_path
  end

  it 'and cant access unauthenticated' do
    visit new_bulk_upload_path

    expect(current_path).to eq new_session_path
  end

  it 'and uploads with success' do
    admin = create(:user, role: :admin)

    Current.session = admin.sessions.create!
    request = ActionDispatch::Request.new(Rails.application.env_config)
    cookies = request.cookie_jar
    cookies.signed[:session_id] = { value: Current.session.id, httponly: true, same_site: :lax }

    visit new_bulk_upload_path

    file_path = Rails.root.join('spec/support/files/script.txt')

    File.open(file_path, "w") do |file|
      file.puts "U,gabriel@toledo.com,Gabriel,Toledo,1"
      file.puts "E,Microsoft,https://microsoft.com,microsoft@email.com,1"
    end

    attach_file 'Arquivo', Rails.root.join('spec/support/files/script.txt')
    click_on 'Upload'

    File.delete(file_path) if File.exist?(file_path)

    expect(current_path).to eq bulk_upload_path(BulkUpload.last)
  end
end
