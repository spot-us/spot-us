require File.dirname(__FILE__) + '/../../spec_helper.rb'

describe "new post" do

  def do_render
    render "/posts/new.html.haml"
  end

  before do
    @fact_checker = Factory(:citizen)
    @fact_checker.stub!(:full_name).and_return('Citizen of the State')
    @reporter = Factory(:reporter)
    @reporter.stub!(:full_name).and_return('Senior Reporter')
    @pitch = Factory(:pitch, :fact_checker => @fact_checker, :user => @reporter)
    @post = Factory(:post, :pitch => @pitch)
    assigns[:pitch] = @pitch
    assigns[:post] = @post
  end
  
  it "should display the fact checkers name" do
    do_render
    response.body.should include(@fact_checker.full_name)
  end

  it "should display the pitch creator" do
    do_render
    response.body.should include(@pitch.user.full_name)
  end

  it "should have a title field" do
    do_render
    response.should have_tag("input[name=?]", "post[title]")
  end

  it "should have a body field" do
    do_render
    response.should have_tag("textarea[name=?]", "post[body]")
  end
end
