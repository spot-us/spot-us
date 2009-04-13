require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')
# rspec is not playing nice
require File.expand_path(File.join(%W(#{RAILS_ROOT} app controllers admin users_controller)))
describe Admin::UsersController do
  describe "get to index" do
    it "should respond to csv" do
      controller.expects(:admin_required).returns(true)
      get :index, :format => "csv"
      response.headers["Content-Type"].should =~ %r(text/csv)
      response.headers["Content-Disposition"].should =~ /attachment; filename=.*?.csv/
    end
  end
end

