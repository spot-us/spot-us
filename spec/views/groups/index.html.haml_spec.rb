require File.dirname(__FILE__) + '/../../spec_helper.rb'

describe "groups index" do
  before do
    @groups = [Factory(:group), Factory(:group)]
    assigns[:groups] = @groups
  end
  it "should list the image for each group" do
    do_render
    @groups.each {|g| response.should have_tag("img[src*=?]", g.image.url) }
  end
  it "should list the name of each group" do
    do_render
    @groups.each {|g| response.body.should include(g.name) }
  end
  it "should list the truncated description of each group" do
    do_render
    @groups.each {|g| response.body.should include(g.description.first(10)) }
  end
  it "should link to each group" do
    do_render
    @groups.each {|g| response.should have_tag("a[href=?]", group_path(g)) }
  end

  def do_render
    render "/groups/index.html.haml"
  end
end
