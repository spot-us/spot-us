require File.dirname(__FILE__) + "/../../../spec_helper"

describe 'profiles/edit' do
  before do
    assigns[:profile] = Factory(:user)
  end
  it "should render" do
    do_render
  end
  
  it "should have a form to update the profile" do
    do_render
    response.should have_tag('form[method = "post"][action = ?]', myspot_profile_path) do
      with_tag('input[name = "_method"][value = "put"]')
    end
  end

  it "should have a field to edit first name" do
    do_render
    response.should have_tag('input[name = ?]', 'profile[first_name]')
  end
  
  it "should have a field to edit last name" do
    do_render
    response.should have_tag('input[name = ?]', 'profile[last_name]')
  end

  it "should display error messages when there are validation errors" do
    template.should_receive(:content_for).with(:error).once
    assigns[:profile].first_name = nil
    violated "The profile must be invalid to test" if assigns[:profile].valid?
    do_render
  end

  def do_render
    render 'myspot/profiles/edit'
  end
end
