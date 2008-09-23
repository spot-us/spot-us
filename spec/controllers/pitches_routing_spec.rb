require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe PitchesController do
  describe "routes" do
    route_matches("/pitches", :get, :controller => "pitches", :action => "index")
    route_matches("/pitches", :post, :controller => "pitches", :action => "create")
    route_matches("/pitches/1", :get, :controller => "pitches", :action => "show", :id => "1")
    route_matches("/pitches/1", :put, :controller => "pitches", :action => "update", :id => "1")
    route_matches("/pitches/1/edit", :get, :controller => "pitches", :action => "edit", :id => "1")
    route_matches("/pitches/new", :get, :controller => "pitches", :action => "new")
    route_matches("/pitches/1", :delete, :controller => "pitches", :action => "destroy", :id => "1")
  end
end
