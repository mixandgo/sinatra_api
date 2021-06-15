require "spec_helper"

RSpec.describe "Questions" do
  describe "POST /presentations/:id/questions" do
    it "requires authentication" do
      post "/presentations/1/questions", { name: "MyQuestion" }
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
        post "/presentations/#{presentation_id}/questions", { name: "MyQuestion" }
        expect(last_response.status).to eq(201)
        body = json_decode(last_response.body)
        expect(body).to match(
          "id" => (be > 0),
          "name" => "MyQuestion",
          "presentation_id" => presentation_id,
          "created_at" => an_instance_of(String)
        )

        get "/presentations/#{presentation_id}/questions"
        expect(last_response.status).to eq(200)
        body = json_decode(last_response.body)
        expect(body.size).to eq(1)
      end
    end
  end
end
