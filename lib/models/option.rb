class Option < Sequel::Model
  plugin :timestamps
  plugin :json_serializer

  many_to_one :question
  one_to_many :votes
end
