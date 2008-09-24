require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe PledgesController do
  describe "on POST to create with valid input" do
    before do
      login_as @user = Factory(:user)
      @tip = Factory(:tip)
    end
    
    it "should create a valid pledge" do
      do_create
      assigns[:pledge].should_not be_nil
      assigns[:pledge].should be_valid
    end

    it "should associate pledge with current user" do
      do_create
      assigns[:pledge].user_id.should == @user.id
    end

    it "should associate pledge with the tip" do
      do_create
      assigns[:pledge].tip.should == @tip
    end

    def do_create
      xhr :post, :create, :pledge => {:tip_id => @tip.id, :amount => 25}
    end
  end
end
