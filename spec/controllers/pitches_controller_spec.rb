require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe PitchesController do
  route_matches("/pitches/1/fully_fund", :put, :id => "1", :controller => "pitches", :action => "fully_fund")
  route_matches("/pitches/1/half_fund", :put, :id => "1", :controller => "pitches", :action => "half_fund")
  route_matches("/pitches/1/show_support", :put, :id => "1", :controller => "pitches", :action => "show_support")
  route_matches("/pitches/1/apply_to_contribute", :get, :id => "1", :controller => "pitches", :action => "apply_to_contribute")
  route_matches("/pitches/1/assign_fact_checker", :put, :id => "1", :controller => "pitches", :action => "assign_fact_checker")
  route_matches("/pitches/1/blog_posts.rss", :get, :id => "1", :controller => "pitches", :action => "blog_posts", :format => "rss")

  describe "on GET to /pitchs/new" do
    before(:each) do
      Pitch.stub!(:createable_by?).and_return(true)
      @user = Factory(:user)
      controller.stubs(:current_user).returns(@user)
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
      pitch = active_pitch(:user => user)
      controller.stubs(:current_user).returns(user)
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
      pitch = active_pitch(:user => user)
      pitch.should be_editable_by(user)
      get :edit, :id => pitch.id
    end

    it "should allow an admin to have access" do
      user = Factory(:admin)
      pitch = active_pitch
      controller.stubs(:current_user).returns(user)
      donation = Factory(:donation, :pitch => pitch, :amount => 3, :status => 'paid')
      get :edit, :id => pitch.id
      flash[:error].should be_nil
    end
  end

  describe "on GET to /pitches/1/edit" do
    describe "without donations" do
      it "renders edit" do
        controller.stubs(:can_edit?).returns(true)
        pitch = Factory(:pitch)
        get :edit, :id => pitch.to_param
        response.should render_template(:edit)
      end
    end
  end

  describe "on PUT to /pitches/1" do
    before do
      @pitch = Factory(:pitch)
      @reporter = @pitch.user
      controller.stubs(:current_user).returns(@reporter)
      controller.stubs(:can_edit?).returns(true)
    end

    it "allows the pitch's reporter to make valid updates" do
      put :update, :id => @pitch.id, :pitch => { :headline => "A New Headline Is Better!" }
      response.should redirect_to(pitch_path(@pitch))
    end
    it "re-renders edit when the pitch's reporter tries to make invalid updates" do
      put :update, :id => @pitch.id, :pitch => { :headline => "" }
      response.should render_template('pitches/edit')
    end
  end

  describe "on PUT to /pitches/1/show_support" do
    before do
      @pitch = Factory(:pitch)
      @organization = Factory(:organization)
      controller.stubs(:current_user).returns(@organization)
    end

    it "requires an organization" do
      controller.stubs(:current_user).returns(Factory(:reporter))
      put :show_support, :id => @pitch.id
      response.should redirect_to(new_session_path)
    end

    it "should redirect back to the pitch" do
      put :show_support, :id => @pitch.to_param
      response.should redirect_to(pitch_path(@pitch))
    end

    it "should call show_support! on the pitch" do
      controller.stubs(:find_resource).returns(@pitch)
      @pitch.should_receive(:show_support!).and_return(true)
      put :show_support, :id => @pitch.id
    end

    it "shows a success message" do
      controller.stubs(:find_resource).returns(@pitch)
      @pitch.stub!(:show_support!).and_return(true)
      put :show_support, :id => @pitch.id
      flash[:success].should_not be_nil
    end
  end

  describe "on GET to /pitches/1/apply_to_contribute" do
    before do
      @pitch = Factory(:pitch)
      @pitch.stub!(:apply_to_contribute)
      @reporter = Factory(:reporter)
      controller.stubs(:current_user).returns(@reporter)
      controller.stubs(:find_resource).returns(@pitch)
    end

    it "adds a reporter to contributors" do
      @pitch.should_receive(:apply_to_contribute)
      get :apply_to_contribute, :id => @pitch.id
    end

    it "adds a new org to contributors" do
      organization = Factory(:organization)
      controller.stubs(:current_user).returns(organization)
      @pitch.should_receive(:apply_to_contribute)
      get :apply_to_contribute, :id => @pitch.id
    end
    it "adds a citizen to contributors" do
      citizen = Factory(:citizen)
      controller.stubs(:current_user).returns(citizen)
      @pitch.should_receive(:apply_to_contribute)
      get :apply_to_contribute, :id => @pitch.id
    end
    it "displays a success message and redirects back to pitch" do
      get :apply_to_contribute, :id => @pitch.id
      flash[:success].should be
      response.should redirect_to(pitch_path(@pitch))
    end
  end

  describe "on PUT to /pitches/1/feature" do
    before do
      @pitch = Factory(:pitch, :id => 17, :feature => true)
    end

    it "should redirect back to the pitch" do
      put :feature, :id => @pitch.to_param
      response.should redirect_to(pitch_path(@pitch))
    end

    it "should call feature! on the pitch" do
      controller.stubs(:find_resource).returns(@pitch)
      @pitch.should_receive(:feature!).and_return(true)
      put :feature, :id => @pitch.id
    end
  end

  describe "on PUT to /pitches/1/unfeature" do
    before do
      @pitch = Factory(:pitch, :id => 17, :feature => true)
    end

    it "should redirect back to the pitch" do
      put :unfeature, :id => @pitch.to_param
      response.should redirect_to(pitch_path(@pitch))
    end

    it "should call feature! on the pitch" do
      controller.stubs(:find_resource).returns(@pitch)
      @pitch.should_receive(:unfeature!).and_return(true)
      put :unfeature, :id => @pitch.id
    end
  end

  describe "on PUT to half_fund" do
    before do
      @organization = Factory(:organization)
      controller.stubs(:current_user).returns(@organization)
      @pitch = Factory(:pitch)
      Pitch.stub!(:find).and_return(@pitch)
    end

    it "requires a logged in user" do
      controller.expects(:current_user).returns(nil)
      put :half_fund, :id => @pitch.id
      response.should redirect_to(new_session_path)
    end

    it "requires the current user is a news organization" do
      controller.stubs(:current_user).returns(Factory(:reporter))
      put :half_fund, :id => @pitch.id
      flash[:error].should_not be_nil
      response.should redirect_to(new_session_path)
    end

    it "creates a donation for half of the amount requested" do
      @pitch.should_receive(:half_fund!).with(@organization)
      put :half_fund, :id => @pitch.id
    end

    it "sets a flash message on success" do
      put :half_fund, :id => @pitch.id
      flash[:success].should_not be_nil
    end

    it "redirects to myspot/donations_amounts/edit on success" do
      put :half_fund, :id => @pitch.id
      response.should redirect_to(edit_myspot_donations_amounts_path)
    end

    describe "on GET to blog_posts.rss" do
      before do
        @pitch = Factory(:pitch)
        @post = Factory(:post, :pitch => @pitch)
        Pitch.stub!(:find).and_return(@pitch)
      end
      it 'renders an rss feed of blog posts' do
        get :blog_posts, :id => @pitch.id, :format => 'rss'
        response.content_type.should == 'application/rss+xml'
      end
    end

    describe "if the donation creation fails" do
      before do
        @pitch.donations.stub!(:create).and_return(false)
      end
      it "should set an error message if the donation creation fails" do
        put :half_fund, :id => @pitch.id
        flash[:error].should_not be_nil
      end
      it "should redirect back to the pitch if the donation creation fails" do
        put :half_fund, :id => @pitch.id
        response.should redirect_to(pitch_path(@pitch))
      end
    end
  end

  describe "on PUT to fully_fund" do
    before do
      @organization = Factory(:organization)
      controller.stubs(:current_user).returns(@organization)
      @pitch = Factory(:pitch)
      Pitch.stub!(:find).and_return(@pitch)
    end

    it "requires a logged in user" do
      controller.expects(:current_user).returns(nil)
      put :fully_fund, :id => @pitch.id
      response.should redirect_to(new_session_path)
    end

    it "requires the current user is a news organization" do
      controller.stubs(:current_user).returns(Factory(:reporter))
      put :fully_fund, :id => @pitch.id
      flash[:error].should_not be_nil
      response.should redirect_to(new_session_path)
    end

    it "creates a donation for the full amount requested" do
      @pitch.should_receive(:fully_fund!).with(@organization)
      put :fully_fund, :id => @pitch.id
    end

    it "sets a flash message on success" do
      put :fully_fund, :id => @pitch.id
      flash[:success].should_not be_nil
    end
    it "redirects to myspot/donations_amounts/edit on success" do
      put :fully_fund, :id => @pitch.id
      response.should redirect_to(edit_myspot_donations_amounts_path)
    end

    describe "if the donation creation fails" do
      before do
        @pitch.donations.stub!(:create).and_return(false)
      end
      it "should set an error message if the donation creation fails" do
        put :fully_fund, :id => @pitch.id
        flash[:error].should_not be_nil
      end
      it "should redirect back to the pitch if the donation creation fails" do
        put :fully_fund, :id => @pitch.id
        response.should redirect_to(pitch_path(@pitch))
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
      controller.stubs(:can_create?).returns(true)
      get :new, :headline => 'example'
    end

    it "should prefill the headline on the pitch" do
      assigns[:pitch].headline.should == 'example'
    end
  end

  describe "on GET to index" do
    it "should redirect to /news_items" do
      get :index
      response.should redirect_to(news_items_path)
    end
  end
end
