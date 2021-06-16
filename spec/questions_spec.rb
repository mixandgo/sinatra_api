require "spec_helper"

RSpec.describe "Questions" do
  describe "POST /questions" do
    it "requires authentication" do
      post "/questions", { name: "MyQuestion", presentation_id: 1 }
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
            category: "marketing",
            presentation_id: presentation_id,
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

        get "/questions?presentation_id=#{presentation_id}"
        expect(last_response.status).to eq(200)
        body = json_decode(last_response.body)
        expect(body.size).to eq(1)

        question_id = body.first["id"]
        get "/options?presentation_id=#{presentation_id}&question_id=#{question_id}"
        body = json_decode(last_response.body)
        expect(body.size).to eq(2)
        expect(body).to include(hash_including("name" => "Option1"))
        expect(body).to include(hash_including("name" => "Option2"))
      end

      context "when the question is invalid" do
        it "returns an error" do
          post "/presentations", { name: "MyPresentation" }
          presentation_id = JSON.parse(last_response.body)["id"]
          post "/questions", { name: "", presentation_id: presentation_id }
          expect(last_response.status).to eq(422)
          json_body = json_decode(last_response.body)
          expect(json_body["errors"]).to include("name is missing")
          expect(json_body["errors"]).to include("category is missing")
        end
      end

      context "when the presentation id is missing" do
        it "returns an error" do
          post "/questions", { name: "" }
          expect(last_response.status).to eq(422)
          json_body = json_decode(last_response.body)
          expect(json_body["errors"]).to include("presentation_id is missing")
        end
      end

      context "when the presentation id is invalid" do
        it "returns an error" do
          post "/questions", { name: "", presentation_id: 1 }
          expect(last_response.status).to eq(422)
          json_body = json_decode(last_response.body)
          expect(json_body["errors"]).to include("presentation not found")
        end
      end
    end
  end
end
