class SubscribersController < ApplicationController
  def create
      @subscriber = Subscriber.new(params[:subscriber])
      if @subscriber.save
        flash[:notice] = "Success! You have been sent a subscription email. Please click the confirmation link in that email to confirm your subscription."\
      else
        flash[:error] = "We're having trouble with that email address. Either it's invalid or you have already signed up to watch this story."
      end
      redirect_to :back
  end
  
  def confirm
    @subscriber = Subscriber.find_by_invite_token(params[:id])
    @subscriber.subscribe if @subscriber
  end
  
  def cancel
    @subscriber = Subscriber.find_by_invite_token(params[:id])
    @subscriber.cancel if @subscriber
  end
end
