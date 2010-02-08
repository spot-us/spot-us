class SectionsController < ApplicationController
  resources_controller_for :sections
  
  def show
    #get help section
    section_id = params[:id].gsub('help_','')
    @section = Section.find_by_name(section_id)
    render :layout => false
  end
end
