require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/stories/edit.html.haml" do
  include ActionView::Helpers::AssetTagHelper

  before(:each) do
    @story = Factory(:story)
    assigns[:story] = @story
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
  it 'includes a textarea for external links' do
    do_render
    response.should have_tag('textarea[name=?]', 'story[external_links]')
  end

  def do_render
    render '/stories/edit.html.haml'
  end

end

