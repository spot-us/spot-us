require File.dirname(__FILE__) + '/../spec_helper'

describe Pitch do
  table_has_columns(Pitch, :integer,   "requested_amount_in_cents")
  table_has_columns(Pitch, :text,     "short_description")
  table_has_columns(Pitch, :text,     "delivery_description")
  table_has_columns(Pitch, :text,     "extended_description")
  table_has_columns(Pitch, :text,     "skills")
  table_has_columns(Pitch, :boolean,  "deliver_text")
  table_has_columns(Pitch, :boolean,  "deliver_audio")
  table_has_columns(Pitch, :boolean,  "deliver_video")
  table_has_columns(Pitch, :boolean,  "deliver_photo")
  table_has_columns(Pitch, :boolean,  "contract_agreement")
  table_has_columns(Pitch, :datetime, "expiration_date")
  table_has_columns(Pitch, :boolean, "feature")

  requires_presence_of Pitch, :requested_amount
  requires_presence_of Pitch, :short_description
  requires_presence_of Pitch, :extended_description
  requires_presence_of Pitch, :delivery_description
  requires_presence_of Pitch, :skills
  requires_presence_of Pitch, :featured_image_caption

  it { Factory(:pitch).should have_many(:affiliations) }
  it { Factory(:pitch).should have_many(:tips) }
  it { Factory(:pitch).should have_many(:donations) }
  it { Factory(:pitch).should have_many(:supporters)}
  it { Factory(:pitch).should have_many(:topics)}

  describe "requested amount" do
    it "normalizes before validation" do
      p = Factory(:pitch, :requested_amount => "1,000")
      p.requested_amount_in_cents.should == 1000.to_cents
    end
  end
  
  describe "current_funding_in_percentage" do
    it "should return the amount of current funding as a percentage of the funding needed" do
      pitch = Factory(:pitch, :requested_amount => "1,000")
      pitch.should_receive(:current_funding_in_cents).and_return(2000)
      pitch.current_funding_in_percentage.should == 0.02
    end
  end
  
  describe "make_featured" do
    it "should unset old pitch and set new pitch" do
      pitch = Factory(:pitch, :feature => true)
      Pitch.featured[0].should == pitch
      pitch2 = Factory(:pitch)
      pitch2.make_featured
      pitch2.reload.feature.should be_true
      pitch.reload.feature.should be_false
    end
    
    it "should just set the pitch to featured if there isn't one already" do
      pitch = Factory(:pitch)
      pitch.make_featured
      pitch.reload.feature.should be_true
    end
  end
  
  describe "editing" do
    before(:each) do
      @pitch = Factory(:pitch, :user => Factory(:user))
    end
  
    it "is editable by its owner" do
      @pitch.editable_by?(@pitch.user).should be_true
    end
  
    it "is not editable by a stranger" do
      @pitch.editable_by?(Factory(:user)).should_not be_true
    end
  
    it "is not editable if not logged in" do
      @pitch.editable_by?(nil).should_not be_true
    end
    
    it "is not editable if has donations" do
      user = Factory(:user)
      p = Factory(:pitch, :user => user, :requested_amount => 100)
      d = Factory(:donation, :pitch => p, :amount => 3, :status => 'paid')
      p.editable_by?(user).should_not be_true
    end
    
    it "is not editable if it is accepted" do
      user = Factory(:user)
      p = Factory(:pitch, :user => user, :requested_amount => 100)
      p.accept!
      p.editable_by?(user).should_not be_true
    end
    
    it "is editable_by an admin even if donations" do
      user = Factory(:admin)
      p = Factory(:pitch, :user => Factory(:user), :requested_amount => 100)
      d = Factory(:donation, :pitch => p, :amount => 3, :status => 'paid')
      p.editable_by?(user).should be_true
    end
    
    it "is editable by admin even if it is accepted" do
      user = Factory(:admin)
      p = Factory(:pitch, :user => Factory(:user), :requested_amount => 100)
      p.accept!
      p.editable_by?(user).should be_true
    end
  end
  
  describe "can_be_accepted?" do
    it "should return true when the state is active" do
      p = Factory(:pitch, :requested_amount => 100)
      p.can_be_accepted?.should be_true
    end
    
    it "should not be true if the state is not active" do
      p = Factory(:pitch, :requested_amount => 100)
      p.fund!
      p.can_be_accepted?.should be_false
    end    
  end
  
  
  describe "states of a pitch" do
    it "should have a state of active when it is first created" do
      pitch = Factory(:pitch)
      pitch.active?.should be_true
    end
    
    it "should have a state of funded when total donations reaches requested amount" do
      pitch = Factory(:pitch, :requested_amount => 100)
      user = Factory(:organization)
      donation = Factory(:donation, :pitch => pitch, :user => user, :amount => 100)

      lambda {
        Factory(:purchase, :donations => [donation], :user => user)
        pitch.reload
      }.should change {pitch.funded?}.from(false).to(true)
    end
        
     it "should have state of accepted when the reporter accepts an amount less than the requested amount" do
       pitch = Factory(:pitch)
       Factory(:donation, :pitch => pitch, :amount => 25)
       lambda {
         pitch.accept!
         pitch.reload
       }.should change {pitch.accepted?}.from(false).to(true)
     end
  end
  
  describe "email notifications" do
    it "should deliver an email when the pitch is accepted!" do
      pitch = Factory(:pitch)
       lambda {
         pitch.accept!
       }.should change { ActionMailer::Base.deliveries.size }.by(1)
    end
  end
  
  describe "most funded" do
    before(:each) do
      @p = Factory(:pitch, :requested_amount => 100)
      @p2 = Factory(:pitch, :requested_amount => 100)
      @p3 = Factory(:pitch, :requested_amount => 100)
      @d = Factory(:donation, :pitch => @p, :amount => 3, :status => 'paid')
      @da = Factory(:donation, :pitch => @p, :amount => 3, :status => 'paid')
      @d2 = Factory(:donation, :pitch => @p2, :amount => 20, :status => 'paid')
      @d3 = Factory(:donation, :pitch => @p3, :amount => 10, :status => 'paid')
    end
    
    it "should return a list of pitches ordered by the funding" do
      @p.reload
      @p2.reload
      @p3.reload
      Pitch.most_funded == [@p2, @p3, @p]
    end
  end
  
  describe "almost funded" do
    before(:each) do
      @p = Factory(:pitch, :requested_amount => 50, :current_funding_in_cents => 2000) #40 %
      @p2 = Factory(:pitch, :requested_amount => 100, :current_funding_in_cents => 1000) #10 %
      @p3 = Factory(:pitch, :requested_amount => 150, :current_funding_in_cents => 2000) #13 %
    end
    
    it "should return a list of pitches ordered by the funding" do
      Pitch.almost_funded == [@p, @p3, @p2]
    end
  end
  
  describe "current_funding" do
    it "should be 0 on a pitch when a donation is added" do
      p = Factory(:pitch, :requested_amount => 100)
      d = Factory(:donation, :pitch => p, :amount => 3)
      p.current_funding_in_cents.should == 0
    end
    
    it "should equal the donation amount when a donation is paid" do
      p = Factory(:pitch, :requested_amount => 100)
      d = Factory(:donation, :pitch => p, :amount => 3)
      purch = Factory(:purchase, :donations => [d])
      p.current_funding_in_cents.should == 300
    end
  end
  
  describe "topics_params=" do
    it "should create topic associations" do
      t = Topic.create(:name => "Topic 1")
      p = Factory(:pitch, :requested_amount => 100)
      p.topics_params=([t.id])
      p.reload
      p.topics.should == [t]      
    end
    
    it "should handle record not found gracefully" do
      p = Factory(:pitch, :requested_amount => 100)
      p.topics_params=([id])
      p.reload
      p.topics.should == []
    end
    
    it "should not add duplicate topics" do
      t = Topic.create(:name => "Topic 1")
      p = Factory(:pitch, :requested_amount => 100)
      p.topics_params=([t.id])
      p.reload
      p.topics.should == [t]
      p.topics_params=([t.id])
      p.reload
      p.topics.size.should == 1
      p.topics.should == [t]
    end
    
    it "should remove topics if they are not part of the values set that comes in" do
      t = Topic.create(:name => "Topic 1")
      t2 = Topic.create(:name => "Topic 2")
      p = Factory(:pitch, :requested_amount => 100)
      p.topics_params=([t.id, t2.id])
      p.reload
      p.topics.should == [t, t2]
      p.topics_params=([t.id])
      p.reload
      p.topics.size.should == 1
      p.topics.should == [t]
    end
  end  
  
  describe "funding_needed_in_cents" do
    it "is equal to requested amount initially" do
      p = Factory(:pitch, :requested_amount => 100)
      p.funding_needed_in_cents.should == 100.to_cents
    end
    
    it "subtracts donations appropriately" do
      p = Factory(:pitch, :requested_amount => 100)
      Factory(:donation, :pitch => p, :amount => 20, :status => 'paid')
      p.funding_needed_in_cents.should == 80.to_cents
    end
    
    it "is 0 when a pitch is accepted" do
      p = Factory(:pitch, :requested_amount => 100)
      p.accept!
      p.funding_needed_in_cents.should == 0.to_cents
    end
    
    it "is 0 when a pitch is fully_funded" do
      p = Factory(:pitch, :requested_amount => 100)
      p.fund!
      p.funding_needed_in_cents.should == 0.to_cents
    end
  end
  
  describe "fully_funded?" do
    it "should return true when total donations equals requested amount" do
      user = Factory(:organization)
      pitch = Factory(:pitch, :user => user, :requested_amount => 100)
      Factory(:donation, :pitch => pitch, :user => user, :amount => 100, :status => 'paid')
      pitch.fully_funded?.should be_true
    end
    
    it "should return true when a pitch is accepted" do
      pitch = Factory(:pitch, :requested_amount => 100)
      pitch.accept!
      pitch.fully_funded?.should be_true
    end
  end
    
  describe "donations.for_user" do
    it "should not return users other than the one requested" do
      user = Factory(:user)
      pitch = Factory(:pitch, :user => Factory(:user), :requested_amount => 100)
      Factory(:donation, :pitch => pitch, :user => user, :amount => 10)
      Factory(:donation, :pitch => pitch, :user => user, :amount => 10)
      Factory(:donation, :pitch => pitch, :user => Factory(:user), :amount => 10)
      pitch.reload
      pitch.donations.for_user(user).size.should == 2
    end
  end  
  
  describe "user_can_donate_more?" do
    describe "any user" do
      it "can't donate more, such that funds would exceed the requested amount" do
        p = Factory(:pitch, :requested_amount => 100)
        p.user_can_donate_more?(Factory(:organization), 1000.to_cents).should be_false
      end

      it "can donate more, as long as funds plus attempted donation are less than requested amount" do
        p = Factory(:pitch, :requested_amount => 100)
        p.user_can_donate_more?(Factory(:organization), 20.to_cents).should be_true
      end
    end
    
    describe "as a citizen or reporter" do
      before(:each) do
        @user = Factory(:user)
        @pitch = Factory(:pitch, :user => Factory(:user), :requested_amount => 100)
      end
    
      it "allows donation if the user has no existing donations" do
        p = Factory(:pitch, :requested_amount => 100)
        p.user_can_donate_more?(Factory(:user), 10.to_cents)
      end
    
      it "return false if the user's total donations + total trying to donate is > 20% of the requested amount" do
        Factory(:donation, :pitch => @pitch, :user => @user, :amount => 10, :status => 'paid')
        Factory(:donation, :pitch => @pitch, :user => @user, :amount => 10, :status => 'paid')
        @pitch.reload
        @pitch.user_can_donate_more?(@user, 10.to_cents).should be_false
      end
    
      it "return true if the user's total donations + total trying to donate is = 20% of the requested amount" do
        Factory(:donation, :pitch => @pitch, :user => @user, :amount => 5)
        Factory(:donation, :pitch => @pitch, :user => @user, :amount => 5)
        @pitch.reload
        @pitch.user_can_donate_more?(@user, 10.to_cents).should be_true
      end
    
      it "return true if the user's total donations + total trying to donate is < 20% of the requested amount" do
        Factory(:donation, :pitch => @pitch, :user => @user, :amount => 3)
        Factory(:donation, :pitch => @pitch, :user => @user, :amount => 5)
        @pitch.reload
        @pitch.user_can_donate_more?(@user, 10.to_cents).should be_true
      end
    end
    
    describe "as a news organization" do
      it "return true even if more than 20% because we are an organization" do
        organization = Factory(:organization)
        pitch = Factory(:pitch, :user => Factory(:user), :requested_amount => 100)
        pitch.user_can_donate_more?(organization, 100.to_cents).should be_true
      end
    end
  end
    
  describe "creating" do
    it "is creatable by reporter" do
      Pitch.createable_by?(Factory(:reporter)).should be
    end
  
    it "is not creatable by user" do
      Pitch.createable_by?(Factory(:user)).should_not be_true
    end
  
    it "is not creatable if not logged in" do
      Pitch.createable_by?(nil).should_not be
    end
  end
  
  describe "featuring" do
    it "is featureable by an admin" do
      user = Factory(:admin)
      pitch = Factory(:pitch)
      pitch.featureable_by?(user).should be_true
    end
    
    it "is not featureable by someone other than admin" do
      user = Factory(:reporter)
      pitch = Factory(:pitch)
      pitch.featureable_by?(user).should be_false
    end
    
    it "is not featureable when user is nil" do
      pitch = Factory(:pitch)
      pitch.featureable_by?(nil).should be_false
    end
  end
  
  it "returns true on #pitch?" do
    Factory(:pitch).should be_a_pitch
  end
  
  it "returns false on #tip?" do
    Factory(:pitch).should_not be_a_tip
  end
  
  it "requires contract_agreement to be true" do
    Factory.build(:pitch, :contract_agreement => false).should_not be_valid
  end
  
  it "requires location to be a valid LOCATION" do
    user = Factory(:user)
    Factory.build(:pitch, :location => LOCATIONS.first, :user => user).should be_valid
    Factory.build(:pitch, :location => "invalid", :user => user).should_not be_valid
  end
  
  describe "to support STI" do
    it "descends from NewItem" do
      Pitch.ancestors.include?(NewsItem)
    end
  end
  
  describe "a pitch with donations" do
    before(:each) do
      @pitch = Factory(:pitch)
      @donation = Factory(:donation, :pitch => @pitch, :status => 'paid')
      @pitch.reload
    end
  
    it "has donations" do
      @pitch.should be_donated_to
    end
    
    it "returns all donated money on total_amount_donated" do
      Factory(:donation, :pitch=> @pitch, :amount => 5)
      Factory(:donation, :pitch=> @pitch, :amount => 2)
      Factory(:donation, :pitch=> @pitch, :amount => 1)
  
      @pitch.reload
      @pitch.total_amount_donated.to_f.should == @pitch.donations.paid.map(&:amount).map(&:to_f).sum
    end
  end
  
  describe "newest pitches" do
    before do
      @items = [Factory(:pitch), Factory(:pitch), Factory(:pitch)]
      @items.reverse.each_with_index do |item, i|
        NewsItem.update_all("created_at = '#{i.days.ago.to_s(:db)}'", "id=#{item.id}")
      end
      Factory(:tip)
      @items.each(&:reload)
      unless @items.collect(&:created_at).uniq.size == 3
        violated "need 3 different created_at values to test sorting"
      end
  
      @result = Pitch.newest
    end
  
    it "should return items in reverse created at order" do
      @result.should == @result.sort {|b, a| a.created_at <=> b.created_at }
    end
  
    it "should return all items" do
      @result.size.should == @items.size
    end
  
    it "should only return pitches" do
      @result.detect {|item| !item.pitch? }.should be_nil
    end
  end
    
  describe "news org funding pitch" do
    it "should allow a news org to fully fund a pitch" do
      pending
    end
    
    it "should allow a news org to match funding if the pitch is less than 50% funded" do
      pending
    end   
  end
end

