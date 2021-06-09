require "sinatra/base"
require "jwt"

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
end
