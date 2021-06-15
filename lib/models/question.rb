class Question < Sequel::Model
  plugin :timestamps
  plugin :json_serializer
end
