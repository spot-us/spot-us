class Myspot::SamplesController < ApplicationController
  resources_controller_for :samples

  before_filter :login_required
  before_filter :assert_reporter
  before_filter :load_collection, :only => [:new]

  protected

  def assert_reporter
    redirect_to root_path and return false unless current_user.reporter?
  end

  def load_collection
    @samples = current_user.samples
  end
end
