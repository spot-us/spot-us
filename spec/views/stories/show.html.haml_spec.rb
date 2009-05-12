require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/stories/show.html.haml" do
  include ActionView::Helpers::AssetTagHelper

  before(:each) do
    @story = Factory(:story)
    assigns[:story] = @story
  end

  it "should render" do
    do_render
  end

  it "should render the headline" do
    do_render
    template.should have_tag('h2.headline', /#{@story.headline}/i)
  end

  it "should have an edit button if the current user is the creator of the story in draft status" do
    template.stub!(:logged_in?).and_return(true)
    template.stub!(:current_user).and_return(@story.user)
    @story.stub!(:draft?).and_return(true)
    @story.stub!(:editable_by?).and_return(true)
    do_render
    template.should have_tag('a[href$=?]', edit_story_path(@story))
  end

  it "should not have an edit button if the current user isn't the creator of the story" do
    template.stub!(:logged_in?).and_return(true)
    template.stub!(:current_user).and_return(Factory(:user))
    do_render
    template.should_not have_tag('a[href$=?]', edit_story_path(@story))
  end

  it "should not have an edit button if not logged in" do
    template.stub!(:logged_in?).and_return(false)
    template.stub!(:current_user).and_return(nil)
    do_render
    template.should_not have_tag('a[href$=?]', edit_story_path(@story))
  end

  it "lists the license if one is available" do
    @story.license = 'the license'
    do_render
    response.should have_text(/the license/)
  end

  it "doesn't list the license header if no license is available" do
    @story.license = nil
    do_render
    response.should_not have_tag("h3", "License")
  end

  it "should have an external links box if there are external links" do
    @story.external_links = "some links"
    do_render
    response.should have_tag("h3", "External Links")
    response.should have_tag(".external_links", "some links")
  end
  it "should not have an external links box otherwise" do
    @story.external_links = nil
    do_render
    response.should_not have_tag("h3", "External Links")
  end

  it "should render short description" do
    do_render
    template.should have_tag('p', /#{@story.short_description}/i)
  end

  it "should render extended description" do
    do_render
    template.should have_tag('div.alt-spotus', /#{@story.extended_description}/i)
  end

  it "should display photo if there is one" do
    assigns[:story].stub!(:featured_image?).and_return(true)
    assigns[:story].stub!(:featured_image).and_return(mock("image", :url => "photo"))
    do_render
    template.should have_tag('img[src = ?]', "/images/photo")
  end

  it "should not display a photo if there isn't one" do
    assigns[:story].stub!(:featured_image?).and_return(false)
    do_render
    template.should_not have_tag('img[src = ?]', "/images/photo")
  end

  it "should display the comments form if the story is published" do
    @story.stub!(:published?).and_return(true)
    do_render
    template.should have_tag('form[action = ?]', story_comments_path(@story))
  end

  it "should not display the comments form if the story is not published" do
    @story.stub!(:published?).and_return(false)
    do_render
    template.should_not have_tag('form[action = ?]', story_comments_path(@story))
  end

  def do_render
    render '/stories/show.html.haml'
  end

end

