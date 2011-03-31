class CcaController < ApplicationController
  before_filter :login_required, :except=>[:show, :index]
  before_filter :load_cca, :only => [:show]
  resources_controller_for :cca

  def index
    @ccas = Cca.live.paginate(:page => params[:page_id])
  end
  
  def show
    if @cca.is_picture_task
      if current_user
        redirect_to check_for_cca_turk_for_pictures
        return 
      else
        session[:return_url] = cca_path(@cca)
        redirect_to new_session_path
        return
      end
    end
    
    @pitch = Pitch.find_by_id(params[:pitch_id]) if params[:pitch_id]
  	if current_user
  		latest_answer = CcaAnswer.latest_answer(@cca,current_user)
  		@cache_form = latest_answer ? latest_answer : nil
  	else
  		@cache_form = nil
  	end
  end
  
  def results
    @cca = find_resource
    
    if @cca && !current_user.is_a?(Admin) && current_user!=@cca.user
      return head(:bad_request)
    end
    
    respond_to do |format|
      format.html do
      end
      format.csv do
        send_data @cca.generate_csv, :type => 'text/csv; charset=iso-8859-1; header=present',
                              :disposition => "attachment; filename=results_#{@cca.to_param}.csv"
      end
    end
  end
  
  def default_answers
    @cca = find_resource
    render :layout=>false
  end
  
  def submit_answers
    @cca = Cca.find_by_id(params[:id])
    tos = params[:tos] || false
    Feedback.sponsor_interest(current_user) if params[:sponsor_interest] # process user signup for being a sponsor
    is_completed = @cca.process_answers(params[:answers], current_user, params[:pitch_id])  # process the survey answers
    if @cca.already_submitted?(current_user)
      # if the user has nav'd back in the browser they could try and submit again -- so we just bring them to the apply credits page
      if params[:pitch_id]
        redirect_to edit_myspot_donations_amounts_path
      else
        redirect_to apply_credits_cca_path(@cca)
      end
    elsif is_completed && tos
      @cca.award_credit(current_user)
      if credit_to_pitch?
        update_balance_cookie
        #redirect_to edit_myspot_donations_amounts_path
        redirect_to apply_credits_pitch_path(@pitch)
      else
        session[:show_default_answers] = @cca.id unless @cca.default_cca_answers.empty?
        update_balance_cookie
        redirect_to apply_credits_cca_path(@cca)
      end
    elsif !tos                                                           # they need to check the TOS box on form
      flash[:error] = "You have to accept the terms of service to complete this survey."
      redirect_to :back
    else
      flash[:error] = "Please answer all questions to earn your credits."
      redirect_to :back
    end
  end 
  
  def apply_credits
    redirect_to "/stories/almost-funded"
    return
  end

  def credit_to_pitch?
  	if params[:pitch_id] and valid_pitch?
  		#Donation.create(:pitch_id => params[:pitch_id], :amount => @cca.award_amount/1.05, :donation_type => "credit", :user_id => current_user.id)
  		return true
  	else 
  		return false
  	end
  end
  
  protected

  def valid_pitch?
  	@pitch = Pitch.find_by_id(params[:pitch_id])
  	if @pitch and !@pitch.fully_funded?
  		true
  	else
  		false
  	end
  end
  
  def load_cca
	if params[:id] == "home"
		cca_home = Cca.cca_home
		@cca = Cca.cca_home.first if cca_home.any?
	else
    	@cca = Cca.find_by_id(params[:id], :include => [:cca_questions, :cca_answers])
	end		
    redirect_to root_url unless @cca && @cca.is_live? || (current_user && current_user.admin?)
  end
  
end
