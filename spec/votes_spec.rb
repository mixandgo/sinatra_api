require "spec_helper"

RSpec.describe "Votes" do
  describe "POST /votes" do
    it "requires authentication" do
      post "/votes", { option_id: 1 }
      expect(last_response.status).to eq(401)
      json_body = json_decode(last_response.body)
      expect(json_body["errors"]).to include("You need to be authenticated")
    end

    context "when client is authenticated" do
      before :each do
        post "/auth", { username: "jdoe", password: "secret" }
        token = json_decode(last_response.body)["token"]
        header "Authorization", "Bearer #{token}"
      end

      it "creates a question" do
        post "/presentations", { name: "MyPresentation" }
        presentation_id = JSON.parse(last_response.body)["id"]
        post "/questions",
          {
            name: "MyQuestion",
            presentation_id: presentation_id,
            category: "marketing",
            options: [{ name: "Option1" }]
          }
        question_id = JSON.parse(last_response.body)["id"]
        get "/options?presentation_id=#{presentation_id}&question_id=#{question_id}"
        option_id = json_decode(last_response.body).first["id"]
        post "/votes", { option_id: option_id }
        expect(last_response.status).to eq(201)
        body = json_decode(last_response.body)
        expect(body).to match(
          "id" => (be > 0),
          "option_id" => option_id,
          "created_at" => an_instance_of(String)
        )
      end

      context "when option_id is missing" do
        it "returns an error" do
          post "/votes", {}
          expect(last_response.status).to eq(422)
          json_body = json_decode(last_response.body)
          expect(json_body["errors"]).to eq("option_id" => ["is missing"])
        end
      end

      context "when an Option with the provided id doesn't exist" do
        it "returns an error" do
          post "/votes", { option_id: 1 }
          expect(last_response.status).to eq(422)
          json_body = json_decode(last_response.body)
          expect(json_body["errors"]).to eq("option_id" => ["is invalid"])
        end
      end
    end
  end
end
