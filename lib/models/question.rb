class Question < Sequel::Model
  plugin :timestamps
  plugin :json_serializer

  many_to_one :presentation
  one_to_many :options

  def validate
    super
    errors.add(:presentation_id, 'is missing') if presentation_id.nil?
    errors.add(:presentation_id, 'is invalid') if presentation_id && Presentation[presentation_id].nil?
    errors.add(:name, 'is missing') if name.nil?
    errors.add(:category, 'is missing') if category.nil?
  end
end
