require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe TipsController do
  describe "routes" do
    route_matches("/tips",        :get,    :controller => "tips", :action => "index")
    route_matches("/tips",        :post,   :controller => "tips", :action => "create")
    route_matches("/tips/1",      :get,    :controller => "tips", :action => "show", :id => "1")
    route_matches("/tips/1",      :put,    :controller => "tips", :action => "update", :id => "1")
    route_matches("/tips/1/edit", :get,    :controller => "tips", :action => "edit", :id => "1")
    route_matches("/tips/new",    :get,    :controller => "tips", :action => "new")
    route_matches("/tips/1",      :delete, :controller => "tips", :action => "destroy", :id => "1")
  end
end
