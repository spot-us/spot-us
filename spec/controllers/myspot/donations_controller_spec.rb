require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Myspot::DonationsController do
  route_matches("/myspot/donations", :get, :controller => "myspot/donations", :action => "index")
end
