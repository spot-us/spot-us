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
  
  describe "on GET to /pitches/1/edit" do
    describe "without donations" do
      it "renders edit" do
        pitch = Factory(:pitch)
        get :edit, :id => pitch.to_param
        response.should render_template(:edit)
      end
    end

    describe "with donations" do
      it "renders edit" do
        donation = Factory(:donation)
        get :edit, :id => donation.pitch.to_param
        response.should redirect_to(pitch_url(donation.pitch))
        flash[:error].should match(/cannot edit a pitch that has donations/i)
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
      Pitch.stub!(:createable_by?).and_return(true)
      get :new, :headline => 'example'
    end

    it "should prefill the headline on the pitch" do
      assigns[:pitch].headline.should == 'example'
    end
  end
end
