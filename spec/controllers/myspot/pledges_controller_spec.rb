require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Myspot::PledgesController do
  route_matches("/myspot/pledges", :get, :controller => "myspot/pledges", :action => "index")
end

