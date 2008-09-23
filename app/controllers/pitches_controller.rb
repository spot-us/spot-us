class PitchesController < ApplicationController
  def index
    @pitches = Pitch.find(:all)
  end

  def show
    @pitch = Pitch.find(params[:id])
  end

  def new
    @pitch = Pitch.new
  end

  def edit
    @pitch = Pitch.find(params[:id])
  end

  def create
    @pitch = Pitch.new(params[:pitch])

    if @pitch.save
      flash[:notice] = 'Pitch was successfully created.'
      redirect_to(@pitch)
    else
      render :action => "new"
    end
  end

  def update
    @pitch = Pitch.find(params[:id])

    if @pitch.update_attributes(params[:pitch])
      flash[:notice] = 'Pitch was successfully updated.'
      redirect_to(@pitch)
    else
      render :action => "edit"
    end
  end

  def destroy
    @pitch = Pitch.find(params[:id])
    @pitch.destroy
    redirect_to(pitches_url)
  end
end
