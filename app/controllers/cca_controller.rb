class CcaController < ApplicationController
  
  def show
    @cca = Cca.find_by_id(params[:id])
   
  end
  
end
