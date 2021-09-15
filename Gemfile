# frozen_string_literal: true

source "https://rubygems.org"

gem "sinatra", require: "sinatra/base"
gem "jwt"
gem "sequel"
gem "sqlite3"
gem "rack-contrib"
gem "sinatra-cors"

group :development do
  gem "pry-byebug"
  gem "rubocop", require: false
end

group :test do
  gem "rspec"
  gem "rack-test"
  gem "webmock"
  gem "simplecov", require: false
# gem "database_cleaner"
end

group :development, :test do
  gem "pry"
end
