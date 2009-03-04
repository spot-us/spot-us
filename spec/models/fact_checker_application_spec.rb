require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe FactCheckerApplication do
  describe "validation" do
    before do
      @application = FactCheckerApplication.new
    end
    it "requires a user" do
      @application.should_not be_valid
      @application.should have(1).error_on(:user)
    end
    it "requires a pitch" do
      @application.should_not be_valid
      @application.should have(1).error_on(:pitch)
    end
    it "requires a unique user and pitch combination" do
      user = Factory(:reporter)
      pitch = Factory(:pitch)
      Factory(:fact_checker_application, :user => user, :pitch => pitch)
      @application.user = user
      @application.pitch = pitch
      @application.should_not be_valid
      @application.should have(1).error_on(:pitch_id)
    end
  end
end
