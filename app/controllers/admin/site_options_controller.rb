class Admin::SiteOptionsController < ApplicationController
  resources_controller_for :site_options
  layout false

  response_for :update do |format|
    format.html do
      redirect_to :back
    end
  end
end
