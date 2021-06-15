class Presentation < Sequel::Model
  plugin :timestamps
  plugin :json_serializer

  one_to_many :questions
end
