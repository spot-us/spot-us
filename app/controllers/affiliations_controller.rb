class AffiliationsController < ApplicationController
  resources_controller_for :affiliations, :only => [:create, :destroy]
end
