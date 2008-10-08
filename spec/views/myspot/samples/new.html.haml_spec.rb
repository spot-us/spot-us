require File.dirname(__FILE__) + "/../../../spec_helper"

describe 'myspot/samples/new' do
  before do
    @reporter = Factory(:reporter)
    template.stub!(:current_user).and_return(@reporter)
    template.stub!(:logged_in?).and_return(true)
    assigns[:sample] = Sample.new
    assigns[:sample].user = @reporter
  end

  it "should render" do
    do_render
  end
  
  it "has edit form" do
    do_render
    response.should have_tag("input[name=?]", "sample[title]")
    response.should have_tag("input[name=?]", "sample[url]")
    response.should have_tag("textarea[name=?]", "sample[description]")
  end
  
  def do_render
    render 'myspot/samples/new'
  end
end
