require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "shared setup", :shared => true do
  before(:each) do
    @anchor_image_regex = /\<a.*href[^>]+\>.*\<img[^>]*\>/
  end
end

describe StoriesHelper do
  include StoriesHelper
  before(:each) do
    @reporter = Factory(:reporter)
    @fact_checker = Factory(:reporter)
    @admin = Factory(:admin)
  end
  describe "as an Admin" do
    describe "when in draft state, the publishing workflow buttons" do
      before(:each) do
        @story = Factory(:story,:user => @reporter, :fact_checker => @fact_checker, :status => 'draft')
      end
      it "should include the 'Edit' button" do
        publishing_workflow_buttons_for(@admin).should =~ /class\=\"edit\"/
      end
    end
    
    describe "when in fact_check state, the publishing workflow buttons" do
      before(:each) do
        @story = Factory(:story,:user => @reporter, :fact_checker => @fact_checker, :status => 'fact_check')
      end
      it "should include the 'Edit' button" do
        publishing_workflow_buttons_for(@admin).should =~ /class\=\"edit\"/
      end
    end
    
    describe "when in ready state, the publishing workflow buttons" do
      before(:each) do
        @story = Factory(:story,:user => @reporter, :fact_checker => @fact_checker, :status => 'ready')
      end
      it "should include the 'Edit' button" do
        publishing_workflow_buttons_for(@admin).should =~ /class\=\"edit\"/
      end
    end
    
    describe "when in published state, the publishing workflow buttons" do
      before(:each) do
        @story = Factory(:story,:user => @reporter, :fact_checker => @fact_checker, :status => 'published')
      end
      it "should include the 'Edit' button" do
        publishing_workflow_buttons_for(@admin).should =~ /class\=\"edit\"/
      end
    end
  end
  
  describe "when in draft state the publishing workflow buttons" do
    before(:each) do
      @story = Factory(:story,:user => @reporter, :fact_checker => @fact_checker, :status => 'draft')
    end
    describe "as an Admin or a Reporter" do
      it "should include 'Edit'" do
        publishing_workflow_buttons_for(@reporter).should =~ /class\=\"edit\"/
        publishing_workflow_buttons_for(@admin).should =~ /class\=\"edit\"/
      end
      it "should include 'Send to Editor'" do
        publishing_workflow_buttons_for(@reporter).should =~ /class\=\"send_to_editor\"/
        publishing_workflow_buttons_for(@admin).should =~ /class\=\"send_to_editor\"/
      end
    end
    describe "as a fact_checker" do
      it_should_behave_like "shared setup"
      
      it "should not see any buttons" do
        publishing_workflow_buttons_for(@fact_checker).should_not =~ @anchor_image_regex
      end
    end
  end
  
  describe "when in fact_check state the publishing workflow buttons" do
    before(:each) do
      @story = Factory(:story,:user => @reporter, :fact_checker => @fact_checker, :status => 'fact_check')
    end
    describe "as an Admin or a fact_checker" do
      it "should include 'Ready for Publishing'" do
        publishing_workflow_buttons_for(@fact_checker).should =~ /class\=\"ready_for_publishing\"/
        publishing_workflow_buttons_for(@admin).should =~ /class\=\"ready_for_publishing\"/
      end
  
      it "should include 'Return to Journalist'" do
        publishing_workflow_buttons_for(@fact_checker).should =~ /class\=\"return_to_journalist\"/
        publishing_workflow_buttons_for(@admin).should =~ /class\=\"return_to_journalist\"/
      end
    end
    
    describe "as a reporter" do
      it_should_behave_like "shared setup"
      
      it "should not see any buttons" do
        publishing_workflow_buttons_for(@reporter).should_not =~ @anchor_image_regex
      end
    end
  end

  describe "when in ready state the publishing workflow buttons" do
    before(:each) do
      @story = Factory(:story,:user => @reporter, :fact_checker => @fact_checker, :status => 'ready')
    end
    describe "as an Admin" do
      it "should include 'Publish'" do
        publishing_workflow_buttons_for(@admin).should =~ /class\=\"publish\"/
      end
    end
    
    describe "as a Reporter or fact_checker" do
      it_should_behave_like "shared setup"
      
      it "should not see any buttons" do
        publishing_workflow_buttons_for(@reporter).should_not =~ @anchor_image_regex
        publishing_workflow_buttons_for(@fact_checker).should_not =~ @anchor_image_regex
      end
    end
  end
  
  describe "when in published state the publishing workflow buttons" do
    before(:each) do
      @story = Factory(:story,:user => @reporter, :fact_checker => @fact_checker, :status => 'published')
    end
    describe "as a Reporter or fact_checker" do
      it_should_behave_like "shared setup"
    
      it "should not see any buttons" do
        publishing_workflow_buttons_for(@reporter).should_not =~ @anchor_image_regex
        publishing_workflow_buttons_for(@fact_checker).should_not =~ @anchor_image_regex
      end
    end
  end
end
