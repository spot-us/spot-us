class CcaController < ApplicationController
  before_filter :login_required
  before_filter :get_cca
  def show
    
  end
  
  def submit_answers
    @cca = Cca.find_by_id(params[:cca_id])
    tos = params[:tos] || false
    Feedback.sponsor_interest(current_user) if params[:sponsor_interest] # process user signup for being a sponsor
    is_completed = @cca.process_answers(params[:answers], current_user)  # process the survey answers
    if is_completed && tos
      @cca.award_credit(current_user)
      redirect_to  "/cca/apply_credits/#{@cca.id}"
    elsif !tos                                                           # they need to check the TOS box on form
      flash[:error] = "You have to accept the terms of service to complete this survey."
      redirect_to :back
    else
      flash[:error] = "Please answer all questions to earn your credits."
      redirect_to :back
    end
  end 
  
  def apply_credits
    @cca = Cca.find_by_id(params[:id])
    @filter = "almost-funded"
    @news_items = NewsItem.constrain_type(@filter).send(@filter.gsub('-','_')).order_results(@filter).browsable.by_network(current_network).paginate(:page => params[:page])
  end
  
  protected
  def get_cca
    @cca = Cca.find_by_id(params[:id])
    redirect_to root_url unless @cca && @cca.is_live? || current_user.admin?
  end
  
end
