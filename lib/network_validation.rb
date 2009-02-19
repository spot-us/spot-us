module NetworkValidation
  def self.included(base)
    base.class_eval do
      before_validation_on_create :set_default_network
      validate :category_in_network
    end
  end

  def set_default_network
    self.network ||= Network.first
  end

  def category_in_network
    errors.add(:category, "must be part of the selected network") unless network.categories.include?(category) || category.nil?
  end
end
