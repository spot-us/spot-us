require File.dirname(__FILE__) + '/../../spec_helper.rb'

describe "blog posts index" do
  def do_render
    render "/posts/index.html.haml"
  end
  before do
    @pitch = Factory(:pitch)
    @post = Factory(:post, :pitch => @pitch)
    assigns[:pitch] = @pitch
    assigns[:posts] = [@post]
  end
  it "should list the title for each post" do
    do_render
    response.should have_tag("h3", @post.title)
  end
  it "should list the date posted" do
    do_render
    response.body.should include(@post.created_at.to_s)
  end
  it "should have a link to read the full post" do
    do_render
    response.should have_tag("a[href=?]", pitch_post_path(@pitch, @post), "Read More")
  end
end
