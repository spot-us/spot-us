require File.dirname(__FILE__) + "/../../../spec_helper"

describe 'profiles/show' do

  include ActionView::Helpers::AssetTagHelper

  before do
    assigns[:profile] = Factory(:user)
  end

  it "should render" do
    do_render
  end

  it "should display a thumbnail when available" do
    url = '/url/to/file.jpg'
    attachment = mock('attachment', :url => url)
    assigns[:profile].stub!(:photo).and_return(attachment)
    do_render
    response.should have_tag('img[src = ?]', url)
  end

  it "should display the missing icon when there is no thumbnail" do
    assigns[:profile].photo?.should be_false
    do_render
    response.should have_tag('img[src = ?]', image_path('default_avatar.png'))
  end
  
  def do_render
    render 'myspot/profiles/show'
  end
end
