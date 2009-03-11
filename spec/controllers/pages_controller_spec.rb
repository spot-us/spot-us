require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe PagesController do

  integrate_views

  route_matches('/pages/about', :get, :controller => 'pages',
                                     :action     => 'show',
                                     :id         => 'about')

  PagesController::PAGES.each do |page|
    it "should successfully render GET show for the #{page} page" do
      get :show, :id => page
      response.should be_success
      response.should render_template(page)
    end
  end

  it "should raise a not found error for a bad page id" do
    lambda { get :show, :id => 'bogus' }.
      should raise_error(ActiveRecord::RecordNotFound)
  end

  describe "index" do
    it "should redirect to the home page" do
      get :index
      response.should redirect_to(root_path)
    end
  end

end
