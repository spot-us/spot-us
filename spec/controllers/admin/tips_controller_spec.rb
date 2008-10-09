require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Admin::TipsController do
  route_matches('/admin/tips', :get, :controller => 'admin/tips',
                                     :action     => 'index')
end