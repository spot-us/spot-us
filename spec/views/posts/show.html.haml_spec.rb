require File.dirname(__FILE__) + '/../../spec_helper.rb'

describe "showing a blog post" do
  def do_render
    render '/posts/show.html.haml'
  end
  before do
    @pitch = Factory(:pitch)
    @post = Factory(:post, :pitch => @pitch)
    assigns[:post] = @post
  end
  it "should link to the pitch" do
    do_render
    response.should have_tag("a[href=?]", pitch_url(@pitch))
  end
  it "should list the title" do
    do_render
    response.body.should include(@post.title)
  end
  it "should show the body" do
    do_render
    response.body.should include(@post.body)
  end
  it "should show the media embed" do
    do_render
    response.body.should include(@post.media_embed)
  end
  it "should show the user" do
    do_render
    response.body.should include(@post.pitch.user.full_name)
  end
  it "should include donations button" do
    do_render
    response.should have_tag("div#inline_donation_form_#{@pitch.id}")
  end
  it "should include the post" do
    do_render
    response.should have_tag("h4", @post.title)
  end
end
