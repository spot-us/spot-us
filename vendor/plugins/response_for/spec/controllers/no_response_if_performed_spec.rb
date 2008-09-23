require File.expand_path(File.join(File.dirname(__FILE__), '../spec_helper'))

module NoResponseIfPerformedSpec
  # example setup
  class TheController < ActionController::Base
    before_filter :redirect
    
    response_for :an_action do |format|
      format.html { in_response_for }
    end
    
  protected
    def redirect
      redirect_to 'http://redirected.from.before_filter'
    end
    
    def in_response_for; end
  end
  
  describe TheController do
    describe "when before_filter redirects, GET :an_action" do
      it "should redirect to 'http://redirected.from.before_filter'" do
        get :an_action
        response.should redirect_to('http://redirected.from.before_filter')
      end
    
      it "should not execute inside response_for" do
        @controller.should_not_receive :in_response_for
        get :an_action
      end
    end
    
    describe "when before_filter doesn't redirect, GET :an_action" do
      before do
        @controller.stub!(:redirect)
      end
      
      it "should execute inside response for" do
        @controller.should_receive :in_response_for
        get :an_action
      end
      
      it "should render :an_action" do
        get :an_action
        response.should render_template(:an_action)
      end
    end
  end
end