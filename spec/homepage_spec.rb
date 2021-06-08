require "spec_helper"

RSpec.describe "Homepage" do
  let(:app) { Api.new }

  describe "GET /" do
    it "returns an empty JSON response" do
      get "/"
      json_body = JSON.parse(last_response.body)
      expect(json_body).to eq({})
    end
  end
end
