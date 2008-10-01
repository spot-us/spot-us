require File.dirname(__FILE__) + "/../../../spec_helper"

describe 'settings/edit' do
  before do
    assigns[:settings] = Factory(:user)
  end

  it "should render" do
    do_render
  end
  
  it "should have a form to update the settings" do
    do_render
    response.should have_tag('form[method = "post"][action = ?]', myspot_settings_path) do
      with_tag('input[name = "_method"][value = "put"]')
    end
  end

  it "should have fields to update the password" do
    do_render
    response.should have_password_field_for(:settings_password)
    response.should have_password_field_for(:settings_password_confirmation)
  end
  
  it "should have check boxes for email notifications" do
    do_render
    response.should have_tag("input[name = ?][type = 'checkbox']", "settings[notify_tips]")
    response.should have_tag("input[name = ?][type = 'checkbox']", "settings[notify_pitches]")
    response.should have_tag("input[name = ?][type = 'checkbox']", "settings[notify_stories]")
    response.should have_tag("input[name = ?][type = 'checkbox']", "settings[notify_spotus_news]")
  end

  address_fields = %w(address1 address2 city state zip)

  describe "for a reporter" do
    before do
      assigns[:settings] = Reporter.new
      do_render
    end

    address_fields.each do |field|
      it "should have a field to edit #{field}" do
        response.should have_text_field_for(:"settings_#{field}")
      end
    end

    it "should have a field to edit country" do
      response.should have_tag('select[name = ?]', 'settings[country]')
    end
  end

  describe "for a non-reporter" do
    before do
      assigns[:settings] = Citizen.new
      do_render
    end

    address_fields.each do |field|
      it "should not have a field to edit #{field}" do
        response.should_not have_text_field_for(:"settings_#{field}")
      end
    end

    it "should not have a field to edit country" do
      response.should_not have_tag('select[name = ?]', 'settings[country]')
    end
  end

  it "should display error messages when there are validation errors" do
    template.should_receive(:content_for).with(:error).once
    assigns[:settings].first_name = nil
    violated "The settings must be invalid to test" if assigns[:settings].valid?
    do_render
  end

  def do_render
    render 'myspot/settings/edit'
  end
end
