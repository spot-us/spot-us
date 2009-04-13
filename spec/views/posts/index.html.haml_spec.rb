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
    do_render
  end
  it "should list the title for each post" do
    response.should have_tag("h3", @post.title)
  end
  it "should list the date posted" do
    response.body.should include(@post.created_at.to_s)
  end
  it "should have a link to read the full post" do
    response.should have_tag("a[href=?]", pitch_post_path(@pitch, @post), "Read More")
  end
  it "should include donations button" do
    response.should have_tag("div#inline_donation_form_#{@pitch.id}")
  end
  it "should include keywords" do
    response.should have_tag("h3", "Keywords")
  end
  it "should include supporters" do
    response.should have_tag("h2", "Supporters")
  end
  it "should have an RSS link" do
    response.should have_tag("a[href=?]", blog_posts_pitch_path(@pitch, :format => :rss))
  end
end
