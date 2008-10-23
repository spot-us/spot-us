require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/pitches/show.html.haml" do
  include ActionView::Helpers::AssetTagHelper

  before(:each) do
    @pitch = Factory(:pitch)
    assigns[:pitch] = @pitch
  end

  it "should render" do
    do_render
  end

  it "should render the headline" do
    do_render
    template.should have_tag('h2.headline', /#{@pitch.headline}/i)
  end
  
  it "should have an edit button if the current user is the creator of the pitch" do
    template.stub!(:logged_in?).and_return(true)
    template.stub!(:current_user).and_return(@pitch.user)
    do_render
    template.should have_tag('a[href$=?]', edit_pitch_path(@pitch))
  end

  it "should not have an edit button if the current user isn't the creator of the pitch" do
    template.stub!(:logged_in?).and_return(true)
    template.stub!(:current_user).and_return(Factory(:user))
    do_render
    template.should_not have_tag('a[href$=?]', edit_pitch_path(@pitch))
  end

  it "should not have an edit button if not logged in" do
    template.stub!(:logged_in?).and_return(false)
    template.stub!(:current_user).and_return(nil)
    do_render
    template.should_not have_tag('a[href$=?]', edit_pitch_path(@pitch))
  end

  it "should render short description" do
    do_render
    template.should have_tag('p', /#{@pitch.short_description}/i)
  end

  it "should display photo if there is one" do
    assigns[:pitch].stub!(:featured_image?).and_return(true)
    assigns[:pitch].stub!(:featured_image).and_return(mock("image", :url => "photo"))
    do_render
    template.should have_tag('img[src = ?]', "/images/photo")
  end
  
  it "should not display a photo if there isn't one" do
    assigns[:pitch].stub!(:featured_image?).and_return(false)
    do_render
    template.should_not have_tag('img[src = ?]', "/images/photo")
  end

  it "not blow up with related pitches" do
    @pitch.tips = [Factory(:tip), Factory(:tip)]
    do_render
  end

  describe "with a guest user" do
    before do
      template.stub!(:logged_in?).and_return(false)
    end

    it "should display a donation button that links to login" do
      do_render
      template.should have_tag('a[href=?]', new_session_path(:news_item_id => @pitch.id)) do
        with_tag('img[src=?]', image_path('donate_25.png'))
      end
    end
  end

  describe "with a logged in user that hasn't donated" do
    before do
      @user = Factory(:user)
      unless @user.donations.empty?
        violated "user should not have any donations"
      end
      template.stub!(:logged_in?).and_return(true)
      template.stub!(:current_user).and_return(@user)
    end

    it "should display a form to add a donation" do
      do_render
      template.should have_tag('form[action=?][method="post"]', donations_path)
    end
  end

  describe "with a logged in user that has donated" do
    before do
      @user = Factory(:user)
      Factory(:donation, :user => @user, :pitch => @pitch, :status => 'unpaid')

      unless @user.donations.detect {|donation| donation.pitch == @pitch }
        violated "user must have donations for the pitch"
      end

      template.stub!(:logged_in?).and_return(true)
      template.stub!(:current_user).and_return(@user)
    end

    it "should have a link to edit donations" do
      do_render
      template.should have_tag('a[href=?]', edit_myspot_donations_amounts_path)
    end

    it "should not display a form to add a donation" do
      do_render
      template.should_not have_tag('form[action=?][method="post"]', donations_path)
    end
  end

  def do_render
    render '/pitches/show.html.haml'
  end

end



