require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Admin::CreditsController do
  describe "GET to index" do
    it "should supply list of credits in descending order" do
      controller.expects(:admin_required).returns(true)
      get :index
      assigns[:credits].should_not be_nil
    end
    
    it "should supply a blank credit for the add credit form" do
      controller.expects(:admin_required).returns(true)
      get :index
      assigns[:credit].should_not be_nil
    end
    
    it "should supply list of users for the add credit form" do
      controller.expects(:admin_required).returns(true)
      get :index
      assigns[:users].should_not be_nil
    end
  end
  
  describe "POST to create" do
    before(:each) do
      login_as Factory(:admin)
      @user = Factory(:user)
    end
    
    it "should create a new credit" do
      @user.credits.should be_empty
      do_post
      @user.reload
      @user.credits.first.amount.to_f.should == 35.0
      @user.credits.first.description.should == "Fatass Sympathy"
    end
    
    it "should redirect to index on successful post" do
      do_post
      response.should redirect_to(admin_credits_path)
    end
    
    it "should not redirect on invalid data" do
      post :create
      response.should render_template("admin/credits/index")
      assigns[:credit].errors.should_not be_empty
    end
    
    def do_post
      post :create, 
           :credit => { :amount => "35",
                        :description => "Fatass Sympathy",
                        :user_id => @user.id }
    end
  end
end
