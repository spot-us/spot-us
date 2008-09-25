class HomesController < ApplicationController

  def show
    @featured_pitch = Pitch.featured
  end

end
