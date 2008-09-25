require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe DonationsController do
  describe "on POST to create with valid input" do
    before do
      login_as @user = Factory(:user)
      @pitch = Factory(:pitch)
    end
    
    it "should create a valid donation" do
      do_create
      assigns[:donation].should_not be_nil
      assigns[:donation].should be_valid
    end

    it "should associate donation with current user" do
      do_create
      assigns[:donation].user_id.should == @user.id
    end

    it "should associate donation with the pitch" do
      do_create
      assigns[:donation].pitch.should == @pitch
    end

    def do_create
      xhr :post, :create, :donation => {:pitch_id => @pitch.id, :amount => 25}
    end
  end

  requires_login_for :post, :create
end
