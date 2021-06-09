require "spec_helper"

RSpec.describe "Homepage" do
  let(:app) { Api.new }

  describe "GET /" do
    it "returns an empty JSON response" do
      get "/"
      body = json_decode(last_response.body)
      expect(body).to eq({})
    end
  end
end
