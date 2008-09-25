require File.dirname(__FILE__) + "/../../spec_helper"

describe 'homes/show' do

  before do
    assigns[:featured_pitch] = Factory(:pitch)
  end

  it 'should render' do
    do_render
  end

  it "should show the featured pitch" do
    do_render
    template.should have_tag('a[href=?]', pitch_path(assigns[:featured_pitch]))
  end

  it "should have a field to enter a headline" do
    do_render
    template.should have_tag('textarea[name="headline"]')
  end

  it "should have a form to create a news item" do
    template.stub!(:start_story_path).and_return('/start/story')
    do_render
    template.should have_tag('form[action=?][method="get"]', '/start/story')
  end

  def do_render
    render 'homes/show'
  end
end
