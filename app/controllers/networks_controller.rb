class NetworksController < ApplicationController

  def categories
    respond_to do |format|
      format.json do
        render :json => Category.find_all_by_network_id(params[:id])
      end
    end
  end

end
