class HomesController < ApplicationController

  def show
    @featured_pitch = Pitch.featured.first
  end

end
