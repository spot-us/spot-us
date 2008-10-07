require File.dirname(__FILE__) + "/../../spec_helper"

describe 'layouts/application' do
  it 'should render' do
    render 'layouts/application'
  end
  
  describe "current balance" do
    before do
      @user = Factory(:user)
      template.stub!(:current_user).and_return(@user)
      template.stub!(:logged_in?).and_return(true)
    end
    
    it "shows no notice when no balance" do
      render 'layouts/application'
      response.should_not have_tag("#current_balance")
    end
    
    it "shows notice when there's a balance" do
      donations = Factory(:donation, :user => @user)
      render 'layouts/application'
      response.should have_tag("#current_balance")
    end    
  end
end
