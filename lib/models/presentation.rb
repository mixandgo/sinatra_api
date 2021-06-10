class Presentation < Sequel::Model
  plugin :timestamps
  plugin :json_serializer
end
