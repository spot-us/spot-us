require File.dirname(__FILE__) + '/../../../spec_helper.rb'

describe "edit group" do
  before do
    assigns[:group] = Factory(:group)
  end

  it "should have a name field" do
    do_render
    response.should have_tag("input[type=text][name=?]", "group[name]")
  end
  it "should have a description box" do
    do_render
    response.should have_tag("textarea[name=?]", "group[description]")
  end

  it "should have an image upload box" do
    do_render
    response.should have_tag("input[type=file][name=?]", "group[image]")
  end

  def do_render
    render "/admin/groups/new.html.haml"
  end

end
