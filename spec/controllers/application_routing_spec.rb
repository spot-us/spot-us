require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ApplicationController do
  describe "routes" do
    it "should redirect /user to home" do
      params_from(:get, '/user').should == {
        :controller => 'homes', :action => 'show', :path=>["user"]
      }
    end
  end
end
