require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/pitches/new.html.haml" do
  include PitchesHelper
  
  before(:each) do
    @pitch = stub_model(Pitch)
    @pitch.stub!(:new_record?).and_return(true)
    assigns[:pitch] = @pitch
  end

  it "should render new form" do
    render "/pitches/new.html.haml"
    
    response.should have_tag("form[action=?][method=post]", pitches_path) do
      with_tag "input[type=submit]"
    end
  end

  %w(requested_amount).each do |field|
    it "renders #{field} as text" do
      render "/pitches/new.html.haml"
      response.should have_tag("form") do
        with_tag "input[type=text][name=?]", "pitch[#{field}]"
      end
    end
  end

  %w(location).each do |field|
    it "renders #{field} as select" do
      render "/pitches/new.html.haml"
      response.should have_tag("form") do
        with_tag "select[name=?]", "pitch[#{field}]"
      end
    end
  end

  %w(headline short_description delivery_description extended_description skills keywords).each do |field|
    it "renders #{field} as textarea" do
      render "/pitches/new.html.haml"
      response.should have_tag("form") do
        with_tag "textarea[name=?]", "pitch[#{field}]"
      end
    end
  end

  %w(deliver_text deliver_audio deliver_video deliver_photo contract_agreement).each do |field|
    it "renders #{field} as checkbox" do
      render "/pitches/new.html.haml"
      response.should have_tag("form") do
        with_tag "input[type=checkbox][name=?]", "pitch[#{field}]"
      end
    end
  end

end


