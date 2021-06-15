class Question < Sequel::Model
  plugin :timestamps
  plugin :json_serializer

  many_to_one :presentation
end
