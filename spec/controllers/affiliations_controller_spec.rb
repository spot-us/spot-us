require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe AffiliationsController do
  route_matches("/affiliations",        :post,   :controller => "affiliations", :action => "create")
  route_matches("/affiliations/1",      :delete, :controller => "affiliations", :action => "destroy", :id => "1")
end
