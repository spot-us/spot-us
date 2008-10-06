require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Myspot::JobsController do
  route_matches("/myspot/profile/jobs/1/edit", :get, :controller => "myspot/jobs", :action => "edit", :id => "1")
end
