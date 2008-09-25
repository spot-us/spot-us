require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe PledgesController do
  describe "routes" do
    route_matches("/pledges",        :get,    :controller => "pledges", :action => "index")
    route_matches("/pledges",        :post,   :controller => "pledges", :action => "create")
    route_matches("/pledges/1",      :get,    :controller => "pledges", :action => "show",   :id => "1")
    route_matches("/pledges/1",      :put,    :controller => "pledges", :action => "update", :id => "1")
    route_matches("/pledges/1/edit", :get,    :controller => "pledges", :action => "edit",   :id => "1")
    route_matches("/pledges/new",    :get,    :controller => "pledges", :action => "new")
    route_matches("/pledges/1",      :delete, :controller => "pledges", :action => "destroy", :id => "1")
  end
end
