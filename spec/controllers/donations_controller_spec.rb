require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe DonationsController do
  describe "on DELETE to destroy" do
    before do
      login_as @user = Factory(:user)
      @donation = Factory(:donation, :user => @user, :paid => true)
    end
    
    it "should remove the donation if paid" do
      Donation.find_by_id(@donation).should_not be_nil
      do_destroy
      Donation.find_by_id(@donation).should be_nil
    end

    it "should redirect to myspot donations AMOUNTS page ie. receipts page" do
      do_destroy
      response.should redirect_to(edit_myspot_donations_amounts_path)
    end

    def do_destroy
      delete :destroy, :id => @donation.id
    end
  end
  
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
