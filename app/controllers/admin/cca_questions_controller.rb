class Admin::CcaQuestionsController < ApplicationController
  before_filter :admin_required
  layout 'bare'

  
  def create
    if CcaQuestion.create(params[:cca_question])
      flash[:success] = "You have successfuly created a new question."
    else
      flash[:error] = "Question could not be created."
    end
    redirect_to :back
  end
  
  def update
    @cca_question = CcaQuestion.find_by_id(params[:id])
    if @cca_question.update_attributes(params[:cca_question])
      flash[:success] = "You have successfuly updated the question."
      redirect_to admin_cca_path(@cca_question.cca)
    else
      redirect_to admin_ccas_path
      flash[:error] = "Question could not be updated."
    end
    
  end
  
  def destroy
    if params[:id]
      if CcaQuestion.destroy(params[:id])
        flash[:success] = "You have successfuly deleted the question."
      else
        flash[:error] = "Question could not be deleted."
      end
    end
    redirect_to :back
  end
  
  def edit
    @cca_question = CcaQuestion.find_by_id(params[:id])
    @cca = @cca_question.cca
    render :template => "/admin/ccas/edit_question"
  end
end