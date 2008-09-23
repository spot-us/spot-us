require File.dirname(__FILE__) + "/../../spec_helper"

describe 'homes/show' do
  it 'should render' do
    do_render
  end

  def do_render
    render 'homes/show'
  end
end
