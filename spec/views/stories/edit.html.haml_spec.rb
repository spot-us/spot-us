require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/stories/edit.html.haml" do
  include ActionView::Helpers::AssetTagHelper

  before(:each) do
    @story = Factory(:story)
    assigns[:story] = @story
    template.stub!(:current_user).and_return(Factory(:reporter))
  end

  it "should render" do
    do_render
  end

  it 'includes a textarea for headline' do
    do_render
    response.should have_tag('textarea[name=?]', 'story[headline]')
  end

  it 'includes a textarea for extended description' do
    do_render
    response.should have_tag('textarea[name=?]', 'story[extended_description]')
  end

  it 'includes a textarea for external links if the user is an admin' do
    template.stubs(:current_user).returns(Factory.build(:admin))
    do_render
    response.should have_tag('textarea[name=?]', 'story[external_links]')
  end

  it "doesn't include the textarea for external links if the user is not an admin" do
    do_render
    response.should_not have_tag('textarea[name=?]', 'story[external_links]')
  end

  it 'includes a license text area if user.admin?' do
    current_user = Factory(:admin)
    current_user.stub!(:admin?).and_return(true)
    template.stub!(:current_user).and_return(current_user)
    do_render
    response.should have_tag('textarea[name=?]', 'story[license]')
  end

  it 'does not include a license text area if !user.admin?' do
    current_user = Factory(:admin)
    current_user.stub!(:admin?).and_return(false)
    template.stub!(:current_user).and_return(current_user)
    do_render
    response.should_not have_tag('textarea[name=?]', 'story[license]')
  end

  def do_render
    render '/stories/edit.html.haml'
  end

end

