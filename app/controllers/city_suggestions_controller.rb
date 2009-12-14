class CitySuggestionsController < ApplicationController
  def create
       @suggestion = CitySuggestion.new(params[:city_suggestion])
       if @suggestion.save
         flash[:notice] = "Thank you for suggesting \"" + @suggestion.city + "\" as a Spot.Us city."
       else
         flash[:error] = "We were not able to process that suggestion. Make sure your email is valid, and you haven't already submitted this city."
       end
       redirect_to :back
   end
end