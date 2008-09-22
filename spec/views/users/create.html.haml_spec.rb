require File.dirname(__FILE__) + "/../../spec_helper"

describe 'users/create' do
  it 'should render' do
    assigns[:title] = mock('title', :null_object => true)
    assigns[:user]  = User.new
        
    render 'users/create'
  end
end
