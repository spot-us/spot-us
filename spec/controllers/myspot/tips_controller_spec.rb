require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Myspot::TipsController do
  route_matches("/myspot/tips", :get, :controller => "myspot/tips", :action => "index")
end

