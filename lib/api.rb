require "sinatra/base"
require "jwt"
require "sequel"
require "rack/contrib"

DB = Sequel.sqlite

DB.create_table :presentations do
  primary_key :id
  String :name
  Time :created_at
end

DB.create_table :questions do
  primary_key :id
  String :name
  String :category
  Integer :presentation_id
  Time :created_at
end

require_relative "models/presentation"
require_relative "models/question"

class Api < Sinatra::Base
  use Rack::JSONBodyParser

  set :default_content_type, "application/json"
  set :logging, true

  configure :test do
    set :dump_errors, true
    set :raise_errors, true
    set :show_exceptions, false
  end

  get "/" do
    {}.to_json
  end

  post "/auth" do
    if params["username"].nil? || params["password"].nil?
      halt 500, { errors: ["Missing username/password params"] }.to_json
    end

    payload = { username: params["username"] }
    token = JWT.encode(payload, "my$ecretK3y", "HS256")

    { token: token }.to_json
  end

  get "/presentations" do
    DB[:presentations].all.to_json
  end

  post "/presentations" do
    halt 401, { errors: ["You need to be authenticated"] }.to_json if env["HTTP_AUTHORIZATION"].nil?
    Presentation.create(name: params["name"]).to_json
  end

  get "/presentations/:id/questions" do
    presentation = Presentation.where(id: params["id"]).first
    presentation.questions.to_json
  end

  post "/presentations/:id/questions" do
    errors = []
    halt 401, { errors: ["You need to be authenticated"] }.to_json if env["HTTP_AUTHORIZATION"].nil?
    errors << "name is missing" if params["name"].nil? || params["name"].empty?
    errors << "category is missing" if params["category"].nil? || params["category"].empty?

    halt 422, { errors: errors }.to_json unless errors.empty?

    status 201
    presentation = Presentation.where(id: params["id"]).first
    presentation.add_question(
      name: params["name"],
      category: params["category"]
    ).to_json
  end

  # start the server if ruby file executed directly
  run! if app_file == $0
end
