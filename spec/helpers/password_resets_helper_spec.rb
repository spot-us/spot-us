require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe PasswordResetsHelper do
  
  include PasswordResetsHelper

  it "should have a blank class name for fields without error" do
    params[:email] = nil
    password_reset_field_class_name.should be_blank
  end

  it "should have an error class name for fields with error" do
    params[:email] = 'anything'
    password_reset_field_class_name.should == 'fieldWithErrors'
  end

end
