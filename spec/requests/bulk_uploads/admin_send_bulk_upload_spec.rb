require 'rails_helper'

RSpec.describe "BulkUploads", type: :request do
  let(:admin) { create(:user, role: :admin) }

  before do
    Current.session = admin.sessions.create!
    request = ActionDispatch::Request.new(Rails.application.env_config)
    cookies = request.cookie_jar
    cookies.signed[:session_id] = { value: Current.session.id, httponly: true, same_site: :lax }
  end

  describe "POST /bulk_uploads" do
    let(:file_path) { Rails.root.join("spec/support/files/script.txt") }
    let(:user) { create(:user, email_address: 'example@user.com') }

    before do
      File.open(file_path, "w") do |file|
        file.puts "U,gabriel@toledo.com,Gabriel,Toledo,1"
        file.puts "E,Microsoft,https://microsoft.com,microsoft@email.com,#{user.id}"
        file.puts "V,Dev Junior,Alguma descrição,5000,brl,Mensal,Remoto,2,Remoto,1,1"
      end
    end

    after do
      File.delete(file_path) if File.exist?(file_path)
    end

    context "when the file is valid" do
      it "creates a bulk upload and enqueues job" do
        file = fixture_file_upload(file_path, "text/plain")

        expect {
          post bulk_uploads_path, params: { file: file }
        }.to change(BulkUpload, :count).by(1)

        expect(response).to redirect_to(bulk_upload_path(BulkUpload.last))
        expect(flash[:notice]).to eq("Your file is being processed")
        expect(enqueued_jobs).to include(hash_including(job: ProcessBulkUploadFileJob))
      end
    end

    context "when no file is provided" do
      it "returns an error" do
        post bulk_uploads_path, params: { file: nil }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include("Please, select a file")
      end
    end

    context "when file is not a text file" do
      it "returns an error" do
        file = fixture_file_upload(Rails.root.join("spec/support/files/logo.jpg"), "image/jpeg")

        post bulk_uploads_path, params: { file: file }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include("Please, select a valid text file")
      end
    end
  end

  describe "GET /bulk_uploads/:id" do
    let!(:bulk_upload) { create(:bulk_upload, user: admin, total_lines: 5) }
    let!(:redis) { Redis.new(url: ENV["REDIS_URL"]) }

    before do
      redis.set("bulk-upload-#{bulk_upload.id}-processed-lines", 3)
      redis.set("bulk-upload-#{bulk_upload.id}-successful", 2)
      redis.set("bulk-upload-#{bulk_upload.id}-errors-count", 1)
      redis.set("bulk-upload-#{bulk_upload.id}-errors-details", [ "Linha 2: Email inválido" ].to_json)
    end

    it "returns bulk upload details" do
      get bulk_upload_path(bulk_upload)

      expect(response).to have_http_status(:success)
      expect(response.body).to include("<strong>Sucesso:</strong> 2")
      expect(response.body).to include("<strong>Erros:</strong> 1")
      expect(response.body).to include("Linha 2: Email inválido")
    end
  end
end
