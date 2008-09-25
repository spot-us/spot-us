require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')


describe "/tips/show.html.haml" do
  before(:each) do
    @tip = Factory(:tip)
    assigns[:tip] = @tip
  end

  it "should render" do
    do_render
  end

  it "should render the headline" do
    do_render
    template.should have_tag('h2.headline', /#{@tip.headline}/i)
  end
  
  it "should have an edit button if the current user is the creator of the tip" do
    template.stub!(:logged_in?).and_return(true)
    template.stub!(:current_user).and_return(@tip.user)
    do_render
    response.should have_tag('a[href$=?]', edit_tip_path(@tip))
  end

  it "should not have an edit button if the current user isn't the creator of the tip" do
    template.stub!(:logged_in?).and_return(true)
    template.stub!(:current_user).and_return(Factory(:user))
    do_render
    response.should_not have_tag('a[href$=?]', edit_tip_path(@tip))
  end

  it "should not have an edit button if not logged in" do
    template.stub!(:logged_in?).and_return(false)
    template.stub!(:current_user).and_return(nil)
    do_render
    response.should_not have_tag('a[href$=?]', edit_tip_path(@tip))
  end
  
  it "should render short description" do
    do_render
    template.should have_tag('p', /#{@tip.short_description}/i)
  end

  it "should display photo if there is one" do
    assigns[:tip].stub!(:featured_image?).and_return(true)
    assigns[:tip].stub!(:featured_image).and_return(mock("image", :url => "photo"))
    do_render
    response.should have_tag('img[src = ?]', "/images/photo")
  end
  
  it "should not display a photo if there isn't one" do
    assigns[:tip].stub!(:featured_image?).and_return(false)
    do_render
    response.should_not have_tag('img[src = ?]', "/images/photo")
  end

  def do_render
    render '/tips/show'
  end

  it "not blow up with related pitches" do
    @tip.pitches = [Factory(:pitch), Factory(:pitch)]
    do_render
  end
end

