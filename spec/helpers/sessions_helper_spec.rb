require File.dirname(__FILE__) + '/../spec_helper'

describe SessionsHelper do
  include SessionsHelper

  it "should set an error class name on both fields if the action is create" do
    params[:controller] = 'sessions'
    params[:action] = 'create'
    session_field_class_name.should == 'fieldWithErrors'
  end

  it "should not set an error class name on both fields if the action is new" do
    params[:controller] = 'sessions'
    params[:action] = 'new'
    session_field_class_name.should be_blank
  end

  it "should return true for login_failed? when a login fails" do
    params[:controller] = 'sessions'
    params[:action] = 'create'
    login_failed?.should be_true
  end

  it "should return false for login_failed? when a login didn't fail" do
    params[:controller] = 'sessions'
    params[:action] = 'new'
    login_failed?.should be_false
  end

end
