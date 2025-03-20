require 'rails_helper'

describe 'User visits upload details', type: :system do
  it 'and fails because is not admin' do
    admin = create(:user, role: :admin, email_address: 'admin@user.com')
    user = create(:user)

    Current.session = user.sessions.create!
    request = ActionDispatch::Request.new(Rails.application.env_config)
    cookies = request.cookie_jar
    cookies.signed[:session_id] = { value: Current.session.id, httponly: true, same_site: :lax }

    bulk_upload = BulkUpload.create(status: 0, total_lines: 2, user: admin)

    visit bulk_upload_path(bulk_upload)

    expect(current_path).to eq root_path
  end

  it 'and cant access unauthenticated' do
    admin = create(:user, role: :admin, email_address: 'admin@user.com')
    bulk_upload = BulkUpload.create(status: 0, total_lines: 2, user: admin)

    visit bulk_upload_path(bulk_upload)

    expect(current_path).to eq new_session_path
  end

  it 'with success', js: true do
    admin = create(:user, role: :admin, email_address: 'admin@user.com')
    user = create(:user)
    bulk_upload = BulkUpload.create!(user: admin, total_lines: 3)

    Current.session = admin.sessions.create!
    request = ActionDispatch::Request.new(Rails.application.env_config)
    cookies = request.cookie_jar
    cookies.signed[:session_id] = { value: Current.session.id, httponly: true, same_site: :lax }

    redis = Redis.new(url: ENV["REDIS_URL"])
    redis.set("bulk-upload-#{bulk_upload.id}-processed-lines", 0)
    redis.set("bulk-upload-#{bulk_upload.id}-successful", 0)
    redis.set("bulk-upload-#{bulk_upload.id}-errors-count", 0)
    redis.set("bulk-upload-#{bulk_upload.id}-errors-details", [].to_json)

    file_data = [
      "U,gabriel@toledo.com,Gabriel,Toledo",
      "E,Microsoft,https://microsoft.com,microsoft@email.com,#{user.id}",
      "V,Dev Junior,Alguma descrição,5000,brl,Mensal,Remoto,2,Remoto,1,1"
    ]

    visit bulk_upload_path(bulk_upload)

    file_data.each_with_index { |line, index| ProcessBulkUploadDataJob.perform_now(bulk_upload.id, index, line) }

    expect(current_path).to eq bulk_upload_path(bulk_upload)
    expect(page).to have_content("Sucesso: 2")
    expect(page).to have_content("Erros: 1")
    expect(page).to have_content("Linha 3: Experience level é obrigatório(a)")
    expect(page).to have_content("Linha 3: Tipo de trabalho é obrigatório")
    expect(page).to have_content("Linha 3: Empresa é obrigatório(a)")
    expect(page).to have_content("Linha 3: Empresa não pode ficar em branco")
  end
end
