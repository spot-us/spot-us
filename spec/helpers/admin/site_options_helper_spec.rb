require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Admin::SiteOptionsHelper do
  include Admin::SiteOptionsHelper

  describe "video_content" do
    it "should ask SiteOption for the value" do
      SiteOption.should_receive(:for).with(:video_content).and_return('a value')
      video_content.should == 'a value'
    end
  end

  describe "change_site_option" do
    it "should load or initialize a site option" do
      stub!(:current_user).and_return(Factory(:admin))
      site_option = SiteOption.create!(:key => :key, :value => 'a value')
      SiteOption.should_receive(:find_or_initialize_by_key).with(:key).and_return(site_option)
      change_site_option(:key)
    end

    it "should give an edit link if the user is an admin" do
      site_option = SiteOption.create!(:key => :key, :value => 'a value')
      SiteOption.stub!(:find_or_initialize_by_key).and_return(site_option)
      stub!(:current_user).and_return(Factory(:admin))
      change_site_option(:key).should have_tag('a[href=?]', edit_admin_site_option_path(site_option))
    end

    it "should return nil if the user is not an admin" do
      stub!(:current_user).and_return(Factory(:citizen))
      change_site_option(:key).should be_nil
    end

    it "should return nil if there is no current_user" do
      stub!(:current_user).and_return(nil)
      change_site_option(:key).should be_nil
    end
  end
end
