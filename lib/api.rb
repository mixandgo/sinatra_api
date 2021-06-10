require "sinatra/base"
require "jwt"
require "sequel"

DB = Sequel.sqlite

DB.create_table :presentations do
  primary_key :id
  String :name
  Time :created_at
end

require "models/presentation"

class Api < Sinatra::Base
  set :dump_errors, true
  set :logging, true
  set :raise_errors, false
  set :show_exceptions, false

  get "/" do
    {}.to_json
  end

  post "/auth" do
    halt 500, { errors: ["Missing username/password params"] }.to_json if params["username"].nil?
    halt 500, { errors: ["Missing username/password params"] }.to_json if params["password"].nil?
    hmac_secret = 'my$ecretK3y'
    payload = { username: params["username"] }
    token = JWT.encode(payload, hmac_secret, 'HS256')

    { token: token }.to_json
  end

  get "/presentations" do
    DB[:presentations].all.to_json
  end

  post "/presentations" do
    halt 401, { errors: ["You need to be authenticated"] }.to_json if env["HTTP_AUTHORIZATION"].nil?
    Presentation.create(name: "MyPresentation").to_json
  end

  # start the server if ruby file executed directly
  run! if app_file == $0
end
