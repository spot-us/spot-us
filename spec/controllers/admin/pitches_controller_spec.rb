require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Admin::PitchesController do
  route_matches('/admin/pitches', :get, :controller => 'admin/pitches', :action => 'index')
  route_matches('/admin/pitches/1/approve', :put, :controller => 'admin/pitches', :action => 'approve', :id => '1')
  route_matches('/admin/pitches/1/unapprove', :put, :controller => 'admin/pitches', :action => 'unapprove', :id => '1')
  route_matches('/admin/pitches/1/approve_blogger', :put, :controller => 'admin/pitches', :action => 'approve_blogger', :id => '1')
  route_matches('/admin/pitches/1/unapprove_blogger', :put, :controller => 'admin/pitches', :action => 'unapprove_blogger', :id => '1')

  before do
    controller.stubs(:current_user).returns(Factory(:admin))
    request.env["HTTP_REFERER"] = root_url
  end

  describe "approve" do
    before do
      @pitch = Factory(:pitch)
    end
    it "should set a flash message" do
      put :approve, :id => @pitch.id
      flash[:success].should_not be_nil
    end
    it "should redirect back" do
      put :approve, :id => @pitch.id
      response.should redirect_to(root_url)
    end
  end

  describe "unapprove" do
    before do
      @pitch = active_pitch
    end
    it "should set a flash message" do
      put :unapprove, :id => @pitch.id
      flash[:success].should_not be_nil
    end
    it "should redirect back" do
      put :unapprove, :id => @pitch.id
      response.should redirect_to(root_url)
    end
  end

  describe "unapprove_blogger" do
    before do
      @pitch = active_pitch
      @pitch.stub!(:unapprove_blogger!)
      @user = Factory(:citizen)
      @application = Factory(:contributor_application, :user => @user, :pitch => @pitch)
      controller.stubs(:current_pitch).returns(@pitch)
    end
    it "should call unapprove! on the application" do
      @pitch.should_receive(:unapprove_blogger!).with(@user.id.to_s)
      do_put
    end
    it "should set a flash message" do
      do_put
      flash[:success].should_not be_nil
    end
    it "should redirect back" do
      do_put
      response.should redirect_to(root_url)
    end
    def do_put
      put :unapprove_blogger, :id => @pitch.id, :user_id => @user.id
    end
  end
end
