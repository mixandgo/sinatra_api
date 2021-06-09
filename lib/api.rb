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
end