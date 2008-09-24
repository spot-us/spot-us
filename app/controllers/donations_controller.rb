class DonationsController < ApplicationController
  resources_controller_for :donation

  private

  def find_resources
    current_user.donations.unpaid
  end
end
