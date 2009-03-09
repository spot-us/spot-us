require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/tips/edit.html.haml" do
  before do
    @tip = Factory(:tip)
    assigns[:tip] = @tip
  end

  it "should render edit form" do
    render "/tips/edit.html.haml"
    response.should have_tag("form[action=#{tip_path(@tip)}][method=post]") 
  end

  it "should render _form partial" do
    template.should_receive(:render).with(:partial => "form")
    render "/tips/edit.html.haml"
  end
end


