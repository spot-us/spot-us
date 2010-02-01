require File.dirname(__FILE__) + "/../../../spec_helper"

describe 'myspot/pitches/index' do
  before do
    @user = Factory(:user)
    @story = Factory(:story)
    @pitch = Factory(:pitch, :user => @user, :story => @story)
    assigns[:pitches] = [@pitch, active_pitch]
    template.stub!(:current_user).and_return(@user)
  end

  it 'should render' do
    do_render
  end

  it "should display a go to story link if the pitch has a story" do
    do_render
    response.should have_tag("a[href=?]", story_path(@story), "Go To Draft")
  end

  it "should display 'pending' if a pitch is awaiting approval" do
    do_render
    response.should have_tag(".status#?", @pitch.id, "Pending approval")
  end

  def do_render
    render 'myspot/pitches/index'
  end
end
