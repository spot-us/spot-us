require File.dirname(__FILE__) + '/../spec_helper'

describe SessionsHelper do
  include SessionsHelper

  it "should set an error class name on both fields if the action is create" do
    params[:action] = 'create'
    session_field_class_name.should == 'fieldWithErrors'
  end

  it "should not set an error class name on both fields if the action is new" do
    params[:action] = 'new'
    session_field_class_name.should be_blank
  end

end
