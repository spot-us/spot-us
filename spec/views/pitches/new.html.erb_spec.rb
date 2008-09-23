require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/pitches/new.html.erb" do
  include PitchesHelper
  
  before(:each) do
    @pitch = mock_model(Pitch)
    @pitch.stub!(:new_record?).and_return(true)
    assigns[:pitch] = @pitch
  end

  it "should render new form" do
    render "/pitches/new.html.erb"
    
    response.should have_tag("form[action=?][method=post]", pitches_path) do
    end
  end
end


