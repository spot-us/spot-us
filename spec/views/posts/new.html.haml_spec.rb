require File.dirname(__FILE__) + '/../../spec_helper.rb'

describe "new post" do

  def do_render
    render "/posts/new.html.haml"
  end
  before do
    @pitch = Factory(:pitch)
    @post = Factory(:post, :pitch => @pitch)
    assigns[:pitch] = @pitch
    assigns[:post] = @post
  end
  it "should have a title field" do
    do_render
    response.should have_tag("input[name=?]", "post[title]")
  end
  it "should have a body field" do
    do_render
    response.should have_tag("textarea[name=?]", "post[body]")
  end
end
