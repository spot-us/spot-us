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
    
    response.should have_tag("form[action=?][method=post][enctype='multipart/form-data']", pitches_path) do
      with_tag "input[type=image]"
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

  it "renders location as select" do
    render "/pitches/new.html.haml"
    response.should have_tag("form") do
      with_tag "select[name=?]", "pitch[location]" do
        LOCATIONS.each do |location|
          with_tag('option[value=?]', location)
        end
      end
    end
  end

  %w(featured_image_caption video_embed headline 
     short_description delivery_description 
     extended_description skills keywords).each do |field|
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

  describe "without errors" do
    before do
      assigns[:pitch].stub!(:valid).and_return(true)
    end

    it "should not display an error message" do
      template.should_receive(:content_for).with(:errors).never
      render "/pitches/new.html.haml"
    end
  end

  describe "with errors" do
    before do
      assigns[:pitch].stub!(:errors).and_return([:one])
    end

    it "should display an error message" do
      template.should_receive(:content_for).once.with(:error)
      render "/pitches/new.html.haml"
    end
  end
end


