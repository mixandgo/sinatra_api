require "spec_helper"

RSpec.describe "Auth" do
  describe "POST /auth" do
    it "requires username & password params" do
      post "/auth"
      expect(last_response.status).to eq(500)
      body = json_decode(last_response.body)
      expect(body["errors"]).to include("Missing username/password params")

      post "/auth", { username: "jdoe" }
      expect(last_response.status).to eq(500)
      body = json_decode(last_response.body)
      expect(body["errors"]).to include("Missing username/password params")

      post "/auth", { password: "secret" }
      expect(last_response.status).to eq(500)
      body = json_decode(last_response.body)
      expect(body["errors"]).to include("Missing username/password params")

      post "/auth", { username: "joe", password: "not_secret" }
      expect(last_response.status).to eq(500)
      body = json_decode(last_response.body)
      expect(body["errors"]).to include("Missing username/password params")
    end

    it "returns a JWT" do
      post "/auth", { username: "jdoe", password: "secret" }
      body = json_decode(last_response.body)
      token = body["token"]
      expect(token).to_not be_nil

      post "/auth", { username: "superman", password: "secret" }
      body = json_decode(last_response.body)
      token2 = body["token"]
      expect(token2).to_not be_nil
      expect(token2).to_not eq(token)
    end
  end
end
