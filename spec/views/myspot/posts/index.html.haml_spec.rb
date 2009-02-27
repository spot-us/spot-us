require File.dirname(__FILE__) + '/../../../spec_helper.rb'

describe "myspot posts index" do
  def do_render
    render '/myspot/posts/index.html.haml'
  end
  before do
    @pitch = Factory(:pitch)
    @post = Factory(:post, :pitch => @pitch)
    assigns[:posts] = [@post]
    login_as Factory(:reporter)
  end
  it "should link to the pitch for each post" do
    do_render
    response.should have_tag("a[href=?]", pitch_url(@pitch), @pitch.headline)
  end
  it "should list the title of each post as a link" do
    do_render
    response.should have_tag("a[href=?]", pitch_post_url(@pitch, @post), @post.title)
  end
end
