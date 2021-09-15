require "spec_helper"

RSpec.describe "Users" do
  it "requires authentication" do
    get "/users/me"
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

    it "returns the user's info" do
      get "/users/me"
      expect(last_response.status).to eq(200)
      body = json_decode(last_response.body)
      expect(body).to match("email" => "jdoe@email.com")
    end
  end
end
