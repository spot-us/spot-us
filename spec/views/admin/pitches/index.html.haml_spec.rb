require File.dirname(__FILE__) + "/../../../spec_helper"

describe '/admin/pitches/index' do
  it "should render" do
    @user = Factory(:admin)
    template.stub!(:current_user).and_return(@user)
    pitches = [Factory(:pitch, :expiration_date => Time.now + 1.day), 
               Factory(:pitch, :expiration_date => Time.now + 1.day)]
    assigns[:pitches] = pitches
    render '/admin/pitches/index'
  end
end
