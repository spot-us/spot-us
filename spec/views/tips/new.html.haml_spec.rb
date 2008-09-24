require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/tips/new.html.haml" do
  before(:each) do
    template.stub!(:current_user).and_return(Factory(:user))
    @tip = stub_model(Tip)
    @tip.stub!(:new_record?).and_return(true)
    assigns[:tip] = @tip
  end

  it "should render new form" do
    render "/tips/new.html.haml"
    
    response.should have_tag("form[action=?][method=post][enctype='multipart/form-data']", tips_path) do
      with_tag "input[type=image]"
    end
  end

  it "renders location as select" do
    render "/tips/new.html.haml"
    response.should have_tag("form") do
      with_tag "select[name=?]", "tip[location]" do
        LOCATIONS.each do |location|
          with_tag('option[value=?]', location)
        end
      end
    end
  end

  %w(featured_image_caption video_embed headline 
     short_description keywords).each do |field|
    it "renders #{field} as textarea" do
      render "/tips/new.html.haml"
      response.should have_tag("form") do
        with_tag "textarea[name=?]", "tip[#{field}]"
      end
    end
  end

  describe "without errors" do
    before do
      assigns[:tip].stub!(:valid).and_return(true)
    end

    it "should not display an error message" do
      template.should_receive(:content_for).with(:errors).never
      render "/tips/new.html.haml"
    end
  end

  describe "with errors" do
    before do
      assigns[:tip].stub!(:errors).and_return([:one])
    end

    it "should display an error message" do
      template.should_receive(:content_for).once.with(:error)
      render "/tips/new.html.haml"
    end
  end
end


