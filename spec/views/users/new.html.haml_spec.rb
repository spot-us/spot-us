require File.dirname(__FILE__) + "/../../spec_helper"

describe 'users/new' do
  it 'should render' do
    template.stub!(:user_path).and_return('')
        
    render 'users/new'
  end
end
