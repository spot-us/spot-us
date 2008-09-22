require File.dirname(__FILE__) + "/../../spec_helper"

describe 'layouts/bare' do
  it 'should render' do
    assigns[:title] = mock('title', :null_object => true)
        
    render 'layouts/bare'
  end
end
