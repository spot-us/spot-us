require File.dirname(__FILE__) + '/../../../spec_helper.rb'

describe "index view" do
  def do_render
    render "/admin/networks/index.html.haml"
  end

  before do
    @networks = [Factory(:network)]
    assigns[:networks] = @networks
  end

  it "should list networks" do
    do_render
    response.should have_tag("span.network_name", @networks.first.name)
  end

  it "should have the display name" do
    do_render
    response.body.should include(@networks.first.display_name)
  end

  it "should have a link to edit" do
    do_render
    response.should have_tag("a[href=?]", edit_admin_network_path(@networks.first), "Edit")
  end

  it "should have a new link" do
    do_render
    response.should have_tag("a[href=?]", new_admin_network_path, 'New network')
  end
end
