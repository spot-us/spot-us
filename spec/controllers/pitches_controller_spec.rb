require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe PitchesController do
  describe "handling GET /pitches" do

    before(:each) do
      @pitch = mock_model(Pitch)
      Pitch.stub!(:find).and_return([@pitch])
    end
  
    def do_get
      get :index
    end
  
    it "should be successful" do
      do_get
      response.should be_success
    end

    it "should render index template" do
      do_get
      response.should render_template('index')
    end
  
    it "should find all pitches" do
      Pitch.should_receive(:find).with(:all).and_return([@pitch])
      do_get
    end
  
    it "should assign the found pitches for the view" do
      do_get
      assigns[:pitches].should == [@pitch]
    end
  end

  describe "handling GET /pitches/1" do

    before(:each) do
      @pitch = mock_model(Pitch)
      Pitch.stub!(:find).and_return(@pitch)
    end
  
    def do_get
      get :show, :id => "1"
    end

    it "should be successful" do
      do_get
      response.should be_success
    end
  
    it "should render show template" do
      do_get
      response.should render_template('show')
    end
  
    it "should find the pitch requested" do
      Pitch.should_receive(:find).with("1").and_return(@pitch)
      do_get
    end
  
    it "should assign the found pitch for the view" do
      do_get
      assigns[:pitch].should equal(@pitch)
    end
  end

  describe "handling GET /pitches/new" do

    before(:each) do
      @pitch = mock_model(Pitch)
      Pitch.stub!(:new).and_return(@pitch)
    end
  
    def do_get
      get :new
    end

    it "should be successful" do
      do_get
      response.should be_success
    end
  
    it "should render new template" do
      do_get
      response.should render_template('new')
    end
  
    it "should create an new pitch" do
      Pitch.should_receive(:new).and_return(@pitch)
      do_get
    end
  
    it "should not save the new pitch" do
      @pitch.should_not_receive(:save)
      do_get
    end
  
    it "should assign the new pitch for the view" do
      do_get
      assigns[:pitch].should equal(@pitch)
    end
  end

  describe "handling GET /pitches/1/edit" do

    before(:each) do
      @pitch = mock_model(Pitch)
      Pitch.stub!(:find).and_return(@pitch)
    end
  
    def do_get
      get :edit, :id => "1"
    end

    it "should be successful" do
      do_get
      response.should be_success
    end
  
    it "should render edit template" do
      do_get
      response.should render_template('edit')
    end
  
    it "should find the pitch requested" do
      Pitch.should_receive(:find).and_return(@pitch)
      do_get
    end
  
    it "should assign the found Pitch for the view" do
      do_get
      assigns[:pitch].should equal(@pitch)
    end
  end

  describe "handling POST /pitches" do

    before(:each) do
      @pitch = mock_model(Pitch, :to_param => "1")
      Pitch.stub!(:new).and_return(@pitch)
    end
    
    describe "with successful save" do
  
      def do_post
        @pitch.should_receive(:save).and_return(true)
        post :create, :pitch => {}
      end
  
      it "should create a new pitch" do
        Pitch.should_receive(:new).with({}).and_return(@pitch)
        do_post
      end

      it "should redirect to the new pitch" do
        do_post
        response.should redirect_to(pitch_url("1"))
      end
      
    end
    
    describe "with failed save" do

      def do_post
        @pitch.should_receive(:save).and_return(false)
        post :create, :pitch => {}
      end
  
      it "should re-render 'new'" do
        do_post
        response.should render_template('new')
      end
      
    end
  end

  describe "handling PUT /pitches/1" do

    before(:each) do
      @pitch = mock_model(Pitch, :to_param => "1")
      Pitch.stub!(:find).and_return(@pitch)
    end
    
    describe "with successful update" do

      def do_put
        @pitch.should_receive(:update_attributes).and_return(true)
        put :update, :id => "1"
      end

      it "should find the pitch requested" do
        Pitch.should_receive(:find).with("1").and_return(@pitch)
        do_put
      end

      it "should update the found pitch" do
        do_put
        assigns(:pitch).should equal(@pitch)
      end

      it "should assign the found pitch for the view" do
        do_put
        assigns(:pitch).should equal(@pitch)
      end

      it "should redirect to the pitch" do
        do_put
        response.should redirect_to(pitch_url("1"))
      end

    end
    
    describe "with failed update" do

      def do_put
        @pitch.should_receive(:update_attributes).and_return(false)
        put :update, :id => "1"
      end

      it "should re-render 'edit'" do
        do_put
        response.should render_template('edit')
      end

    end
  end

  describe "handling DELETE /pitches/1" do

    before(:each) do
      @pitch = mock_model(Pitch, :destroy => true)
      Pitch.stub!(:find).and_return(@pitch)
    end
  
    def do_delete
      delete :destroy, :id => "1"
    end

    it "should find the pitch requested" do
      Pitch.should_receive(:find).with("1").and_return(@pitch)
      do_delete
    end
  
    it "should call destroy on the found pitch" do
      @pitch.should_receive(:destroy)
      do_delete
    end
  
    it "should redirect to the pitches list" do
      do_delete
      response.should redirect_to(pitches_url)
    end
  end
end
