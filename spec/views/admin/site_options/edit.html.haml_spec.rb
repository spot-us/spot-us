require File.dirname(__FILE__) + '/../../../spec_helper.rb'

describe "edit" do

  def do_render
    @site_option = Factory(:site_option)
    assigns[:site_option] = @site_option
    render "/admin/site_options/edit"
  end

  it "should use a wysiwyg editor" do
    do_render
    response.body.should have_tag("textarea[id=?]", "site_option_#{@site_option.id}_value_editor")
  end
end
