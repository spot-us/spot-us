class CcaController < ApplicationController
  
  def show
    @cca = User.find_by_id(1)
  end
  
end
