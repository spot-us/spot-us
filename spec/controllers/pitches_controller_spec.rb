require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe PitchesController do
  describe "on GET to /pitchs/new" do
    before(:each) do
      @user = Factory(:user)
      controller.stub!(:current_user).and_return(@user)
      get :new
    end

    it "assigns the new pitch the current user" do
      assigns(:pitch).user_id.should == @user.id
    end
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
end
