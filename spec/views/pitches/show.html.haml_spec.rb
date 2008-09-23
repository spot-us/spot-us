require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/pitches/show.html.erb" do
  include PitchesHelper
  
  before(:each) do
    @pitch = mock_model(Pitch)

    assigns[:pitch] = @pitch
  end

  it "should render attributes in <p>" do
    render "/pitches/show.html.erb"
  end
end

