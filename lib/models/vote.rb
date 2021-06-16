class Vote < Sequel::Model
  plugin :timestamps
  plugin :json_serializer

  many_to_one :option

  def validate
    super
    errors.add(:option_id, 'is missing') if option_id.nil?
    errors.add(:option_id, 'is invalid') if option_id && Option[option_id].nil?
  end
end

