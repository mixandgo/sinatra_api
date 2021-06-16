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
        post "/presentations/#{presentation_id}/questions",
          {
            name: "MyQuestion",
            category: "marketing",
            options: [{ name: "Option1" }, { name: "Option2" }]
          }
        expect(last_response.status).to eq(201)
        body = json_decode(last_response.body)
        expect(body).to match(
          "id" => (be > 0),
          "name" => "MyQuestion",
          "category" => "marketing",
          "presentation_id" => presentation_id,
          "created_at" => an_instance_of(String)
        )

        get "/presentations/#{presentation_id}/questions"
        expect(last_response.status).to eq(200)
        body = json_decode(last_response.body)
        expect(body.size).to eq(1)

        question_id = body.first["id"]
        get "/presentations/#{presentation_id}/questions/#{question_id}/options"
        body = json_decode(last_response.body)
        expect(body.size).to eq(2)
        expect(body).to include(hash_including("name" => "Option1"))
        expect(body).to include(hash_including("name" => "Option2"))
      end

      context "when the question is invalid" do
        it "returns an error" do
          post "/presentations", { name: "MyPresentation" }
          presentation_id = JSON.parse(last_response.body)["id"]
          post "/presentations/#{presentation_id}/questions", { name: "" }
          expect(last_response.status).to eq(422)
          json_body = json_decode(last_response.body)
          expect(json_body["errors"]).to include("name is missing")
          expect(json_body["errors"]).to include("category is missing")
        end
      end
    end
  end
end
