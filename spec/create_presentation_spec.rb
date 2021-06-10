require "spec_helper"

RSpec.describe "Create presentation" do
  let(:app) { Api.new }

  describe "POST /presentations" do
    it "requires authentication" do
      post "/presentations", { name: "MyPresentation" }
      expect(last_response.status).to eq(401)
      json_body = json_decode(last_response.body)
      expect(json_body["errors"]).to include("You need to be authenticated")
    end

    context "when client is authenticated" do
      before :each do
        post "/auth", { username: "jdoe", password: "secret" }
        token = json_decode(last_response.body)["token"]
        header "Content-Type", "application/json"
        header "Authorization", "Bearer #{token}"
      end

      it "creates a presentation" do
        post "/presentations", { name: "MyPresentation" }
        expect(last_response.status).to eq(200)
        body = json_decode(last_response.body)
        expect(body).to match(
          "id" => (be > 0),
          "name" => "MyPresentation",
          "created_at" => an_instance_of(String)
        )
      end

      it "persists the presentation created" do
        post "/presentations", { name: "MyPresentation" }
        get "/presentations"
        expect(last_response.status).to eq(200)
        body = json_decode(last_response.body)
        expect(body.first).to match(
          "id" => (be > 0),
          "name" => "MyPresentation",
          "created_at" => an_instance_of(String)
        )
      end
    end
  end
end
