require File.dirname(__FILE__) + '/../spec_helper'

describe Story do
  requires_presence_of Story, :extended_description
  requires_presence_of Story, :headline
  requires_presence_of Story, :location
  
  it { Factory(:story).should belong_to(:pitch) }
  it { Factory(:story).should belong_to(:user) }
  it { Factory(:story).should belong_to(:fact_checker) }
  it { Factory(:story).should have_many(:supporters) }
  
  describe "to support STI" do
    it "descends from NewItem" do
      Story.ancestors.include?(NewsItem)
    end
  end
  
  describe "A Story's status" do
    before(:each) do
      @story = Factory(:story)
    end
    
    it "should be initialized as 'draft'" do
      @story.should be_draft
    end
    
    it "should transition from 'draft' to 'fact_check'" do
      @story.verify!
      @story.should be_fact_check
    end
    
    it "should transition from 'fact_check' to 'draft'" do
      @story.verify!
      @story.reject!
      @story.should be_draft
    end
    
    it "should transition from 'fact_check' to 'ready'" do
      @story.verify!
      @story.accept!
      @story.should be_ready
    end
    
    it "should transition from 'ready' to 'published'" do
      @story.verify!
      @story.accept!
      @story.publish!
      @story.should be_published
    end
  end

end