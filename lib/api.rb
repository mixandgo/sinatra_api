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

DB.create_table :options do
  primary_key :id
  String :name
  Integer :question_id
  Time :created_at
end

DB.create_table :votes do
  primary_key :id
  Integer :option_id
  Time :created_at
end

require_relative "models/presentation"
require_relative "models/question"
require_relative "models/option"
require_relative "models/vote"

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
    authenticate!
    DB[:presentations].all.to_json
  end

  post "/presentations" do
    authenticate!
    Presentation.create(name: params["name"]).to_json
  end

  get "/questions" do
    authenticate!

    presentation = Presentation.where(id: params["presentation_id"]).first
    presentation.questions.to_json
  end

  post "/questions" do
    authenticate!

    question = Question.new(
      name: params["name"],
      category: params["category"],
      presentation_id: params["presentation_id"]
    )
    halt 422, { errors: question.errors }.to_json unless question.valid?

    question.save
    status 201

    if !params["options"].nil?
      options = params["options"].map { |opt| question.add_option(opt) }
    end

    question.to_json
  end

  get "/options" do
    Option.where(question_id: params["question_id"]).to_json
  end

  post "/votes" do
    authenticate!

    vote = Vote.new(option_id: params["option_id"])
    halt 422, { errors: vote.errors }.to_json unless vote.valid?

    status 201
    vote.save
    vote.to_json
  end

  def param_required(name)
    params[name].nil? || params[name].empty?
  end

  def authenticate!
    halt 401, { errors: ["You need to be authenticated"] }
      .to_json if env["HTTP_AUTHORIZATION"].nil?
  end
  # start the server if ruby file executed directly
  run! if app_file == $0
end
