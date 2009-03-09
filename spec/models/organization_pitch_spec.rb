require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe OrganizationPitch do
  describe "validation" do
    before do
      @organization_pitch = OrganizationPitch.new
    end
    it "should belong to an organization" do
      @organization_pitch.should respond_to(:organization)
    end
    it "should require an organization" do
      @organization_pitch.should_not be_valid
      @organization_pitch.should have(1).errors_on(:organization)
    end
    it "should belong to a pitch" do
      @organization_pitch.should respond_to(:pitch)
    end
    it "should require a pitch" do
      @organization_pitch.should_not be_valid
      @organization_pitch.should have(1).errors_on(:pitch)
    end
    it "should only allow an organization to support a pitch once" do
      other_op = Factory(:organization_pitch)
      @organization_pitch.organization = other_op.organization
      @organization_pitch.pitch = other_op.pitch
      @organization_pitch.should_not be_valid
      @organization_pitch.should have(1).errors_on(:pitch_id)
    end
  end
end
