require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Admin::PitchesController do
  route_matches('/admin/pitches', :get, :controller => 'admin/pitches',
                                     :action     => 'index')
end