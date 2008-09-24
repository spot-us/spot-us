require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe PitchesController do
  describe "routes" do
    route_matches("/donations",        :get,    :controller => "donations", :action => "index")
    route_matches("/donations",        :post,   :controller => "donations", :action => "create")
    route_matches("/donations/1",      :get,    :controller => "donations", :action => "show", :id => "1")
    route_matches("/donations/1",      :put,    :controller => "donations", :action => "update", :id => "1")
    route_matches("/donations/1/edit", :get,    :controller => "donations", :action => "edit", :id => "1")
    route_matches("/donations/new",    :get,    :controller => "donations", :action => "new")
    route_matches("/donations/1",      :delete, :controller => "donations", :action => "destroy", :id => "1")
  end
end
