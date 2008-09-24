require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/tips/index.html.haml" do
  before(:each) do
    assigns[:tips] = [mock_model(Tip), mock_model(Tip)]
  end

  it "should render list of tips" do
    render "/tips/index.html.haml"
  end
end

