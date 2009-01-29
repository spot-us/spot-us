require File.dirname(__FILE__) + "/../../spec_helper"

describe 'users/activation_email' do
  it "should have an email input field" do
    do_render
    response.should have_tag('input[name=email]')
  end

  def do_render
    render 'users/activation_email'
  end
end
