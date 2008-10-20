module DonationsHelper
  def store_location
    controller.send(:store_location)
  end
end