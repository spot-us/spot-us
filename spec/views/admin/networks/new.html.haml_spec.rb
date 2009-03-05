require File.dirname(__FILE__) + '/../../../spec_helper.rb'

describe "new view" do

  def do_render
    render "/admin/networks/new.html.haml"
  end

  before do
    assigns[:network] = Network.new
  end

  it "should have a name field" do
    do_render
    response.should have_tag("input[name=?]", "network[name]")
  end

  it "should have a display name field" do
    do_render
    response.should have_tag("input[name=?]", "network[display_name]")
  end
  
  it "should have a submit field" do
    do_render
    response.should have_tag("input[type=?]", "submit")
  end

  it "has an errors span" do
    do_render
    response.should have_tag("div.error")
  end
end
