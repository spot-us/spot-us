require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe StoriesController do

  route_matches('/stories/1/edit', :get, :controller => 'stories',
                                               :action     => 'edit',
                                               :id => "1")

  route_matches('/stories/1', :put, :controller => 'stories',
                                          :action     => 'update',
                                          :id => "1")
                                          
  route_matches('/stories/1', :get, :controller => 'stories',
                                          :action     => 'show',
                                          :id => "1")
                                               
end