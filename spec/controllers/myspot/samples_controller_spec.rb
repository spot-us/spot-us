require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Myspot::SamplesController do
  route_matches("/myspot/profile/samples/1/edit", :get, :controller => "myspot/samples", :action => "edit", :id => "1")
end