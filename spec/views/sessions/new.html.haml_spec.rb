require File.dirname(__FILE__) + "/../../spec_helper"

describe 'sessions/new' do
  it 'should render' do
    template.stub!(:check).and_return(mock('check_return_value', :null_object => true))
    template.stub!(:session_path).and_return('')
        
    render 'sessions/new'
  end
end
