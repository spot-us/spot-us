require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe AffiliationsController do
  route_matches("/affiliations",        :post,   :controller => "affiliations", :action => "create")
  route_matches("/affiliations/1",      :delete, :controller => "affiliations", :action => "destroy", :id => "1")

  describe "creating" do
    before do
      @reporter = Factory(:reporter)
      @pitch = Factory(:pitch, :user => @reporter)
      @tip = Factory(:tip)
      @affiliation = Affiliation.new(:tip => @tip, :pitch => @pitch)
      controller.stubs(:new_resource).returns(@affiliation)
      controller.stubs(:current_user).returns(@reporter)
    end
    it "requires the current user to be the pitch's reporter" do
      @affiliation.stub!(:createable_by?).and_return(false)
      do_create
      response.should redirect_to(new_session_path)
    end
    it "redirects back to tip and displays an error message when it fails" do
      @affiliation.stub!(:createable_by?).and_return(true)
      controller.stubs(:resource_saved?).returns(false)
      do_create
      flash[:error].should_not be_nil
      response.should redirect_to(tip_path(@tip))
    end
    it "redirects back to tip and displays a success message when it succeeds" do
      @affiliation.stub!(:createable_by?).and_return(true)
      controller.stubs(:resource_saved?).returns(true)
      do_create
      flash[:success].should_not be_nil
      response.should redirect_to(tip_path(@tip))
    end

    def do_create
      post :create, :affiliation => {:tip_id => @tip, :pitch_id => @pitch}
    end
  end
end
