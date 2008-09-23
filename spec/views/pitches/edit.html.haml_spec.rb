require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/pitches/edit.html.haml" do
  include PitchesHelper
  
  before do
    @pitch = mock_model(Pitch)
    assigns[:pitch] = @pitch
  end

  it "should render edit form" do
    render "/pitches/edit.html.haml"
    
    response.should have_tag("form[action=#{pitch_path(@pitch)}][method=post]") do
    end
  end
end


