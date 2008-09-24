require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/tips/show.html.haml" do
  before(:each) do
    @tip = mock_model(Tip)

    assigns[:tip] = @tip
  end

  it "should render attributes in <p>" do
    render "/tips/show.html.haml"
  end
end

