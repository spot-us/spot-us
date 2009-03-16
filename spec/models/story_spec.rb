require File.dirname(__FILE__) + '/../spec_helper'

describe Story do

  requires_presence_of Story, :headline

  it { Factory(:story).should belong_to(:pitch) }
  it { Factory(:story).should belong_to(:user) }

  describe "to support STI" do
    it "descends from NewItem" do
      Story.ancestors.should include(NewsItem)
    end
  end

  describe "validation" do
    it "should allow p tags in extended description" do
      story = Factory(:story)
      story.extended_description = "<p>Some html</p>"
      story.save
      story.extended_description.should include("<p>")
    end
  end
  describe "status" do
    before(:each) do
      @story = Factory(:story)
    end

    it "should be initialized as 'draft'" do
      @story.should be_draft
    end

    it "should transition from 'draft' to 'fact_check'" do
      @story.update_attribute(:status,'draft')
      @story.verify!
      @story.should be_fact_check
    end

    it "should transition from 'fact_check' to 'ready'" do
      Mailer.stub!(:deliver_story_ready_notification)
      @story.update_attribute(:status,'fact_check')
      @story.accept!
      @story.should be_ready
    end

    it "should send an email notification when ready" do
      Mailer.stub!(:deliver_story_ready_notification)
      @story.should_receive(:notify_admin)
      @story.update_attribute(:status,'fact_check')
      @story.accept!
    end

    it "should transition from 'fact_check' to 'draft'" do
      @story.update_attribute(:status,'fact_check')
      @story.reject!
      @story.should be_draft
    end

    it "should transition from 'ready' to 'published'" do
      @story.update_attribute(:status,'ready')
      @story.publish!
      @story.should be_published
    end
  end

  describe "story in draft state" do
    describe "editable_by?" do
      before do
        @citizen = Factory(:citizen)
        @reporter = Factory(:reporter)
        @fact_checker = Factory(:reporter)
        @admin = Factory(:admin)
        @story = Factory(:story, :status => 'draft')
      end
      it "should be true for the reporter" do
        @story.user = @reporter
        @story.save
        @story.editable_by?(@reporter).should be_true
      end

      it "should be true for the admin" do
        @story.user = @reporter
        @story.save
        @story.editable_by?(@admin).should be_true
      end

      it "should be false for the fact check editor" do
        @story.user = @reporter
        @story.fact_checker = @fact_checker
        @story.save
        @story.editable_by?(@fact_checker).should be_false
      end

      it "should be false for anyone else who is logged in" do
        @story.user = @reporter
        @story.save
        @story.editable_by?(@citizen).should be_false
      end

      it "should be false for anyone not logged in" do
        @story.user = @reporter
        @story.save
        @story.editable_by?(nil).should be_false
      end
    end
  end


  describe "story in fack_check state" do
    before do
      @citizen = Factory(:user)
      @reporter = Factory(:reporter)
      @fact_checker = Factory(:reporter)
      @admin = Factory(:admin)
      @story = Factory(:story, :status => 'fact_check')
    end
    describe "editable_by?" do
      it "should be false for the reporter" do
        @story.user = @reporter
        @story.save
        @story.editable_by?(@reporter).should be_false
      end

      it "should be false for the fact check editor" do
        @story.user = @reporter
        @story.fact_checker = @fact_checker
        @story.save
        @story.editable_by?(@fact_checker).should be_false
      end
    end
  end

  describe "story in ready state" do
    before do
      @citizen = Factory(:citizen)
      @reporter = Factory(:reporter)
      @fact_checker = Factory(:reporter)
      @admin = Factory(:admin)
      @story = Factory(:story, :status => 'ready')
    end
    describe "editable_by?" do
      it "should be false for the reporter" do
        @story.user = @reporter
        @story.save
        @story.editable_by?(@reporter).should be_false
      end

      it "should be false for the fact check editor" do
        @story.user = @reporter
        @story.fact_checker = @fact_checker
        @story.save
        @story.editable_by?(@fact_checker).should be_false
      end
    end
  end

  describe "story in published state" do
    before do
      @citizen = Factory(:citizen)
      @reporter = Factory(:reporter)
      @fact_checker = Factory(:reporter)
      @admin = Factory(:admin)
      @story = Factory(:story, :status => 'published')
    end
    describe "editable_by?" do
      it "should be false for the reporter" do
        @story.user = @reporter
        @story.save
        @story.editable_by?(@reporter).should be_false
      end

      it "should be false for the fact check editor" do
        @story.user = @reporter
        @story.fact_checker = @fact_checker
        @story.save
        @story.editable_by?(@fact_checker).should be_false
      end
    end
  end

  describe "story in draft state" do
    describe "viewable_by?" do
      before do
        @citizen = Factory(:citizen)
        @reporter = Factory(:reporter)
        @fact_checker = Factory(:reporter)
        @admin = Factory(:admin)
        @story = Factory(:story, :status => 'draft')
      end
      it "should be true for the reporter" do
        @story.user = @reporter
        @story.save
        @story.viewable_by?(@reporter).should be_true
      end

      it "should be true for the fact check editor" do
        @story.user = @reporter
        @story.fact_checker = @fact_checker
        @story.save
        @story.viewable_by?(@fact_checker).should be_true
      end

      it "should be true for an admin" do
        @story.user = @reporter
        @story.save
        @story.viewable_by?(@admin).should be_true
      end

      it "should be false for anyone else in the system" do
        @story.user = @reporter
        @story.save
        @story.viewable_by?(@citizen).should be_false
      end

      it "should be false for anyone not logged in" do
        @story.user = @reporter
        @story.save
        @story.viewable_by?(nil).should be_false
      end
    end
  end

  describe "story in fact_check state" do
    before do
      @citizen = Factory(:citizen)
      @reporter = Factory(:reporter)
      @fact_checker = Factory(:reporter)
      @admin = Factory(:admin)
      @story = Factory(:story, :status => 'fact_check')
    end
    describe "viewable_by?" do
      it "should be true for the reporter" do
        @story.user = @reporter
        @story.save
        @story.viewable_by?(@reporter).should be_true
      end

      it "should be true for the fact check editor" do
        @story.user = @reporter
        @story.fact_checker = @fact_checker
        @story.save
        @story.viewable_by?(@fact_checker).should be_true
      end

      it "should be true for an admin" do
        @story.user = @reporter
        @story.save
        @story.viewable_by?(@admin).should be_true
      end

      it "should be false for anyone else in the system" do
        @story.user = @reporter
        @story.save
        @story.viewable_by?(@citizen).should be_false
      end

      it "should be false for anyone not logged in" do
        @story.user = @reporter
        @story.save
        @story.viewable_by?(nil).should be_false
      end

    end
  end

  describe "story in ready state" do
    before do
      @citizen = Factory(:citizen)
      @reporter = Factory(:reporter)
      @fact_checker = Factory(:reporter)
      @admin = Factory(:admin)
      @story = Factory(:story, :status => 'ready')
    end
    describe "viewable_by?" do
      it "should be true for the reporter" do
        @story.user = @reporter
        @story.save
        @story.viewable_by?(@reporter).should be_true
      end

      it "should be true for the fact check editor" do
        @story.user = @reporter
        @story.fact_checker = @fact_checker
        @story.save
        @story.viewable_by?(@fact_checker).should be_true
      end

      it "should be true for an admin" do
        @story.user = @reporter
        @story.save
        @story.viewable_by?(@admin).should be_true
      end

      it "should be false for anyone else in the system" do
        @story.user = @reporter
        @story.save
        @story.viewable_by?(@citizen).should be_false
      end

      it "should be false for anyone not logged in" do
        @story.user = @reporter
        @story.save
        @story.viewable_by?(nil).should be_false
      end
    end
  end

  describe "story in publish state" do
    before do
      @citizen = Factory(:citizen)
      @reporter = Factory(:reporter)
      @fact_checker = Factory(:reporter)
      @admin = Factory(:admin)
      @story = Factory(:story, :status => 'published')
    end
    describe "viewable_by?" do
      it "should be true for the reporter" do
        @story.user = @reporter
        @story.save
        @story.viewable_by?(@reporter).should be_true
      end

      it "should be true for the fact check editor" do
        @story.user = @reporter
        @story.fact_checker = @fact_checker
        @story.save
        @story.viewable_by?(@fact_checker).should be_true
      end

      it "should be true for an admin" do
        @story.user = @reporter
        @story.save
        @story.viewable_by?(@admin).should be_true
      end

      it "should be true for anyone else in the system" do
        @story.user = @reporter
        @story.save
        @story.viewable_by?(@citizen).should be_true
      end

      it "should be true for anyone not logged in" do
        @story.user = @reporter
        @story.save
        @story.viewable_by?(nil).should be_true
      end
    end
  end
    describe "story in fact_check state" do
      before do
        @citizen = Factory(:citizen)
        @reporter = Factory(:reporter)
        @fact_checker = Factory(:reporter)
        @admin = Factory(:admin)
        @story = Factory(:story, :status => 'fact_check')
      end
      describe "fact_checkable_by?" do
        it "should be false for the reporter" do
          @story.user = @reporter
          @story.fact_checker = @fact_checker
          @story.save
          @story.fact_checkable_by?(@reporter).should be_false
        end

        it "should be true for the admin" do
          @story.user = @reporter
          @story.fact_checker = @fact_checker
          @story.save
          @story.fact_checkable_by?(@admin).should be_true
        end

        it "should be true for the fact checker" do
          @story.user = @reporter
          @story.fact_checker = @fact_checker
          @story.save
          @story.fact_checkable_by?(@fact_checker).should be_true
        end
      end
    end

    describe "publishable_by?" do
      before do
        @citizen = Factory(:citizen)
        @reporter = Factory(:reporter)
        @fact_checker = Factory(:reporter)
        @admin = Factory(:admin)
        @story = Factory(:story, :status => 'ready')
      end
      it "should be true for the admin" do
        @story.user = @reporter
        @story.save
        @story.publishable_by?(@admin).should be_true
      end

      it "should false for anyone else" do
        @story.user = @reporter
        @story.save
        @story.publishable_by?(@reporter).should be_false
      end

      it "should be false for anyone not logged in" do
        @story.user = @reporter
        @story.save
        @story.publishable_by?(nil).should be_false
      end
    end
end
