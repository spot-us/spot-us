require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Admin::PitchesController do
  route_matches('/admin/pitches', :get, :controller => 'admin/pitches', :action => 'index')
  route_matches('/admin/pitches/1/approve', :put, :controller => 'admin/pitches', :action => 'approve', :id => '1')
  route_matches('/admin/pitches/1/unapprove', :put, :controller => 'admin/pitches', :action => 'unapprove', :id => '1')
end
