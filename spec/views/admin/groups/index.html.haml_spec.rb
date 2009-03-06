require File.dirname(__FILE__) + '/../../../spec_helper.rb'

describe "viewing all groups" do
  before do
    @groups = [Factory(:group), Factory(:group)]
    assigns[:groups] = @groups
  end
  it "displays group names" do
    do_render
    @groups.each do |group|
      response.body.should include(group.name)
    end
  end
  it "displays an edit link" do
    do_render
    @groups.each do |group|
      response.should have_tag("a[href=?]", edit_admin_group_path(group))
    end
  end
  it "displays a delete link" do
    do_render
    @groups.each do |group|
      response.should have_tag("a[href=?]", admin_group_path(group), "Destroy")
    end
  end
  it 'displays a new link' do
    do_render
    response.should have_tag("a[href=?]", new_admin_group_path)
  end

  def do_render
    render "/admin/groups/index.html.haml"
  end

end
