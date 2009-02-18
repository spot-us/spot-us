require File.dirname(__FILE__) + '/../../../spec_helper.rb'

describe "edit view" do

  def do_render
    render "admin/networks/edit.html.haml"
  end

  before do
    assigns[:network] = Factory(:network)
  end

  it "should have a name field" do
    do_render
    response.should have_tag("input[name=?]", "network[name]")
  end

  it "should have a submit button" do
    do_render
    response.should have_tag("input[type=submit]")
  end

  it "should have a link to the network index" do
    do_render
    response.should have_tag("a[href=?]", admin_networks_path, "All networks")
  end

end
