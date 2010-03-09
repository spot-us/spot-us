class SectionsController < ApplicationController
  resources_controller_for :sections, :only=>[:show]
  
  def show
    #get help section
    section_id = params[:id].gsub('help_','')
    @section = Section.find_by_name(section_id)
    render :layout => false
  end

  def link
    @page_url = params[:url]
    @width = params[:width] ? params[:width] : "950"
    @height = params[:height] ? params[:height] : "600"
    render :layout => false
  end
end
