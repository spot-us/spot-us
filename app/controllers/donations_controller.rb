class DonationsController < ApplicationController

  resources_controller_for :donations

  private

  def find_resources
    current_user.donations.unpaid
  end
end
