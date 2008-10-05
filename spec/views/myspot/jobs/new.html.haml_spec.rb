require File.dirname(__FILE__) + "/../../../spec_helper"

describe 'myspot/jobs/new' do
  before do
    @reporter = Factory(:reporter)
    template.stub!(:current_user).and_return(@reporter)
    template.stub!(:logged_in?).and_return(true)
    assigns[:job] = Job.new
    assigns[:job].user = @reporter
  end

  it "should render" do
    do_render
  end
  
  it "has edit form" do
    do_render
    response.should have_tag("input[name=?]", "job[title]")
    response.should have_tag("input[name=?]", "job[url]")
    response.should have_tag("textarea[name=?]", "job[description]")
  end
  
  def do_render
    render 'myspot/jobs/new'
  end
end
