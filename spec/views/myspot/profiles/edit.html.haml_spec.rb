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
  
  it "should have a field to edit the user photo" do
    do_render
    response.should have_tag('input[type = "file"][name = ?]', 'profile[photo]')
  end

  it "should have a field to edit 'about you'" do
    do_render
    response.should have_tag('textarea[name = ?]', 'profile[about_you]')
  end

  it "should have a field to edit website" do
    do_render
    response.should have_tag('input[name = ?]', 'profile[website]')
  end

  it "should have a dropdown to edit the network" do
    do_render
    response.should have_tag('select[name = ?]', 'profile[network_id]') do
      Network.all.map(&:id).each do |network_id|
        with_tag('option[value=?]', network_id)
      end
    end
  end

  it "should have a link to view the profile" do
    do_render
    response.should have_tag('a[href = ?]', myspot_profile_path)
  end
  it "should have a multipart form" do
    do_render
    response.should have_tag('form[enctype = ?]', 'multipart/form-data')
  end

  it "should display a thumbnail when available" do
    url = '/url/to/file.jpg'
    attachment = mock('attachment', :url => url)
    assigns[:profile].stub!(:photo).and_return(attachment)
    do_render
    response.should have_tag('img[src = ?]', url)
  end

  it "should display error messages when there are validation errors" do
    template.should_receive(:content_for).with(:error).once
    assigns[:profile].first_name = nil
    violated "The profile must be invalid to test" if assigns[:profile].valid?
    do_render
  end

  describe "for a reporter" do
    before do
      assigns[:profile] = Reporter.new
      do_render
    end

    it "has a check box for fact-check editor interest" do
      response.should have_tag("input[name = ?][type = 'checkbox']", "profile[fact_check_interest]")
    end
  end

  def do_render
    render 'myspot/profiles/edit'
  end
end
