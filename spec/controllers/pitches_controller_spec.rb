require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe PitchesController do
  describe "on GET to /pitchs/new" do
    before(:each) do
      Pitch.stub!(:createable_by?).and_return(true)
      @user = Factory(:user)
      controller.stub!(:current_user).and_return(@user)
      get :new
    end

    it "assigns the new pitch the current user" do
      assigns(:pitch).user_id.should == @user.id
    end
  end

  describe "when can't create on new" do
    before(:each) do
      Pitch.stub!(:createable_by?).and_return(false)
      get :new
    end
    it_denies_access
  end

  describe "when can't edit" do
    it "should deny access and add flash when not owner" do
      user = Factory(:user)
      pitch = Factory(:pitch, :user => Factory(:user))
      Pitch.stub!(:find).and_return(pitch)
      get :edit, :id => pitch.id
      flash[:error].should match(/You cannot edit this pitch, since you didn't create it./)
      response.should redirect_to(pitch_path(pitch))
    end
    
    it "should deny access and add flash when donations added" do
      user = Factory(:user)
      pitch = Factory(:pitch, :user => user)
      controller.stub!(:current_user).and_return(user)
      donation = Factory(:donation, :pitch => pitch, :amount => 2, :status => 'paid')
      Pitch.stub!(:find).and_return(pitch)
      get :edit, :id => pitch.id
      flash[:error].should match(/You cannot edit a pitch that has donations.  For minor changes, contact info@spot.us/)
      response.should redirect_to(pitch_path(pitch))
    end
  end
  
  describe "can_edit?" do
    it "should allow the owner of a pitch to have access" do
      user = Factory(:user)
      pitch = Factory(:pitch, :user => user)
      pitch.should be_editable_by(user)
      get :edit, :id => pitch.id 
    end
    
    it "should allow an admin to have access" do
      user = Factory(:admin)
      pitch = Factory(:pitch)
      controller.stub!(:current_user).and_return(user)
      donation = Factory(:donation, :pitch => pitch, :amount => 3, :status => 'paid')
      get :edit, :id => pitch.id
      flash[:error].should be_nil
    end
  end
  
  describe "on GET to /pitches/1/edit" do
    describe "without donations" do
      it "renders edit" do
        controller.stub!(:can_edit?).and_return(true)
        pitch = Factory(:pitch)
        get :edit, :id => pitch.to_param
        response.should render_template(:edit)
      end
    end
  end

  describe "on GET to show" do
    before do
      @pitch = Factory(:pitch)
    end

    it "should store the location in the session" do
      do_show
      session[:return_to].should == pitch_path(@pitch)
    end

    def do_show
      get :show, :id => @pitch.id
    end
  end

  describe "on GET to new with a headline" do
    before do
      login_as Factory(:user)
      controller.stub!(:can_create?).and_return(true)
      get :new, :headline => 'example'
    end

    it "should prefill the headline on the pitch" do
      assigns[:pitch].headline.should == 'example'
    end
  end
end
