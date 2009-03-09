module NetworkMethods
  def self.included(base)
    base.class_eval do
      belongs_to :network
      before_validation_on_create :set_default_network
      validates_presence_of :network
      validate :category_in_network
    end
  end

  def set_default_network
    self.network ||= Network.first
  end

  def category_in_network
    errors.add(:category, "must be part of the selected network") unless network.nil? || network.categories.include?(category) || category.nil?
  end

  def network_and_category
    return "No network selected" unless network
    output =  network.display_name
    output += "- #{category.name}" if category
    output
  end
end
