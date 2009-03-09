require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/pitches/edit.html.haml" do
  include PitchesHelper
  
  before do
    @pitch = Factory(:pitch)
    assigns[:pitch] = @pitch
  end

  it "should render edit form" do
    render "/pitches/edit.html.haml"
    response.should have_tag("form[action=#{pitch_path(@pitch)}][method=post]") 
  end

  it "should render _form partial" do
    template.should_receive(:render).with(:partial => "form")
    render "/pitches/edit.html.haml"
  end
end

