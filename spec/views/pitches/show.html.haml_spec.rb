require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/pitches/show.html.haml" do
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
    response.should have_tag('a[href$=?]', edit_pitch_path(@pitch))
  end

  it "should not have an edit button if the current user isn't the creator of the pitch" do
    template.stub!(:logged_in?).and_return(true)
    template.stub!(:current_user).and_return(Factory(:user))
    do_render
    response.should_not have_tag('a[href$=?]', edit_pitch_path(@pitch))
  end

  it "should not have an edit button if not logged in" do
    template.stub!(:logged_in?).and_return(false)
    template.stub!(:current_user).and_return(nil)
    do_render
    response.should_not have_tag('a[href$=?]', edit_pitch_path(@pitch))
  end
  
  it "should render short description" do
    do_render
    template.should have_tag('p', /#{@pitch.short_description}/i)
  end

  it "should display photo if there is one" do
    assigns[:pitch].stub!(:featured_image?).and_return(true)
    assigns[:pitch].stub!(:featured_image).and_return(mock("image", :url => "photo"))
    do_render
    response.should have_tag('img[src = ?]', "/images/photo")
  end
  
  it "should not display a photo if there isn't one" do
    assigns[:pitch].stub!(:featured_image?).and_return(false)
    do_render
    response.should_not have_tag('img[src = ?]', "/images/photo")
  end

  def do_render
    render '/pitches/show.html.haml'
  end

  it "not blow up with related pitches" do
    @pitch.tips = [Factory(:tip), Factory(:tip)]
    do_render
  end
end



