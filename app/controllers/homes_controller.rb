class HomesController < ApplicationController
  # caches_page :show

  def show
    @featured_pitch = Pitch.featured.first
  end

end
