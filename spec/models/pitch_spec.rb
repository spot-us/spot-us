require File.dirname(__FILE__) + '/../spec_helper'

describe Pitch do
  table_has_columns(Pitch, :decimal,  "requested_amount")
  table_has_columns(Pitch, :decimal,  "current_funding")
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
  it { Factory(:pitch).should have_many(:comments)}
  it { Factory(:pitch).should have_many(:contributor_applications)}
  it { Factory(:pitch).should have_many(:contributor_applicants)}
  it { Factory(:pitch).should have_many(:contributors)}

  describe "requested amount" do
    it "normalizes before validation" do
      p = Factory(:pitch, :requested_amount => "1,000")
      p.requested_amount.should == 1000
    end
  end

  describe "current_funding_in_percentage" do
    before do
      @pitch = Factory(:pitch, :requested_amount => "1,000")
    end

    it "should return 0 if current_funding is 0" do
      @pitch.current_funding = 0
      @pitch.current_funding_in_percentage.should == 0
    end

    it "should return 0 if current_funding is nil" do
      @pitch.current_funding = nil
      @pitch.current_funding_in_percentage.should == 0
    end

    it "should return the amount of current funding as a percentage of the funding needed" do
      @pitch.should_receive(:current_funding).and_return(20)
      @pitch.current_funding_in_percentage.should == 0.02
    end
  end

  describe "notifications" do
    it 'emails the admin when a pitch is created' do
      Mailer.should_receive(:deliver_pitch_created_notification)
      Factory(:pitch)
    end
    it 'does not email the admin when a pitch is updated' do
      p = active_pitch
      Mailer.should_not_receive(:deliver_pitch_created_notification)
      p.accept!
    end
    it 'emails the reporter when the pitch is approved' do
      p = Factory(:pitch)
      Mailer.should_receive(:deliver_pitch_approved_notification)
      p.approve!
    end
  end

  describe "editing" do
    before(:each) do
      @pitch = active_pitch(:user => Factory(:user))
    end

    describe "in the active state" do
      it "is editable by its owner" do
        @pitch.editable_by?(@pitch.user).should be_true
      end
      it "is not editable by a stranger" do
        @pitch.editable_by?(Factory(:user)).should_not be_true
      end
      it "is not editable if not logged in" do
        @pitch.editable_by?(nil).should_not be_true
      end
    end

    describe "in the unapproved state" do
      before do
        @pitch.update_attribute(:status, 'unapproved')
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
    end


    it "is not editable if has donations" do
      user = Factory(:user)
      p = active_pitch(:user => user, :requested_amount => 100)
      d = Factory(:donation, :pitch => p, :amount => 3, :status => 'paid')
      p.editable_by?(user).should_not be_true
    end

    it "is not editable if it is accepted" do
      user = Factory(:user)
      p = active_pitch(:user => user, :requested_amount => 100)
      p.accept!
      p.editable_by?(user).should_not be_true
    end

    it "is editable_by an admin even if donations" do
      user = Factory(:admin)
      p = active_pitch(:user => Factory(:user), :requested_amount => 100)
      d = Factory(:donation, :pitch => p, :amount => 3, :status => 'paid')
      p.editable_by?(user).should be_true
    end

    it "is editable by admin even if it is accepted" do
      user = Factory(:admin)
      p = active_pitch(:user => Factory(:user), :requested_amount => 100)
      p.accept!
      p.editable_by?(user).should be_true
    end
  end

  describe "can_be_accepted?" do
    it "should return true when the state is active" do
      p = active_pitch(:requested_amount => 100)
      p.can_be_accepted?.should be_true
    end

    it "should not be true if the state is not active" do
      p = active_pitch(:requested_amount => 100)
      p.fund!
      p.can_be_accepted?.should be_false
    end

  end


  describe "states of a pitch" do
    it "should have a state of unapproved when it is first created" do
      pitch = Factory(:pitch)
      pitch.should be_unapproved
    end

    it "should have a state of active when it is approved" do
      pitch = active_pitch
      pitch.should be_active
    end

    it "should have a state of unapproved when it is unapproved" do
      pitch = active_pitch
      pitch.unapprove!
      pitch.should be_unapproved
    end

    it "should have a state of funded when total donations reaches requested amount" do
      pitch = active_pitch
      pitch.update_attribute(:requested_amount, 100)
      user = Factory(:organization)
      donation = Factory(:donation, :pitch => pitch, :user => user, :amount => 100)

      lambda {
        Factory(:purchase, :donations => [donation], :user => user)
        pitch.reload
      }.should change {pitch.funded?}.from(false).to(true)
    end

    it "should have state of accepted when the reporter accepts an amount less than the requested amount" do
      pitch = active_pitch(:requested_amount => 1000)
      Factory(:donation, :pitch => pitch, :amount => 10)
      lambda {
        pitch.accept!
        pitch.reload
      }.should change {pitch.accepted?}.from(false).to(true)
    end
  end

  describe "email notifications" do
    it "should deliver an email when the pitch is accepted!" do
      pitch = active_pitch
       lambda {
         pitch.accept!
       }.should change { ActionMailer::Base.deliveries.size }.by(1)
    end
  end

  describe "most funded" do
    before(:each) do
      @p = active_pitch(:requested_amount => 100)
      @p2 = active_pitch(:requested_amount => 100)
      @p3 = active_pitch(:requested_amount => 100)
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

  describe "featured" do
    it "should be randomized" do
      Pitch.featured.proxy_options[:order].should match(/rand\(\)/i)
    end
  end

  describe "almost funded" do
    before(:each) do
      @p = active_pitch(:requested_amount => 50, :current_funding => 20) #40 %
      @p2 = active_pitch(:requested_amount => 100, :current_funding => 10) #10 %
      @p3 = active_pitch(:requested_amount => 150, :current_funding => 20) #13 %
      @p4 = Factory(:pitch, :requested_amount => 100, :current_funding => 50, :status => 'accepted') #50%
    end

    it "should return a list of pitches ordered by the funding" do
      Pitch.almost_funded.first.should == @p
      Pitch.almost_funded.last.should == @p4
    end

  end

  describe "current_funding" do
    it "should be 0 on a pitch when a donation is added" do
      p = active_pitch(:requested_amount => 100)
      d = Factory(:donation, :pitch => p, :amount => 3)
      p.current_funding.should == 0
    end

    it "should equal the donation amount when a donation is paid" do
      p = active_pitch(:requested_amount => 100)
      d = Factory(:donation, :pitch => p, :amount => 3)
      purch = Factory(:purchase, :donations => [d])
      p.current_funding.should == BigDecimal.new("3.0")
    end

    it "should return total amount donated if accepted" do
      p = active_pitch(:requested_amount => 100)
      d = Factory(:donation, :pitch => p, :amount => 3, :status => 'paid')
      p.accept!
      p.current_funding.should == BigDecimal.new("3.0")
    end
    it "should return requested amount if there is an overage" do
      p = active_pitch(:requested_amount => 100)
      d = Factory(:donation, :pitch => p, :amount => 3, :status => 'paid')
      p.fully_fund!(Factory(:organization)).pay!
      p.reload.current_funding.should == BigDecimal("100.0")
    end
  end

  describe "topics_params=" do
    it "should create topic associations" do
      t = Topic.create(:name => "Topic 1")
      p = active_pitch(:requested_amount => 100)
      p.topics_params=([t.id])
      p.reload
      p.topics.should == [t]
    end

    it "should handle record not found gracefully" do
      p = active_pitch(:requested_amount => 100)
      p.topics_params=([nil])
      p.reload
      p.topics.should == []
    end

    it "should not add duplicate topics" do
      t = Topic.create(:name => "Topic 1")
      p = active_pitch(:requested_amount => 100)
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

  describe "funding_needed" do
    before do
      @pitch = active_pitch(:requested_amount => 100)
    end
    it "is equal to requested amount initially" do
      @pitch.funding_needed.should == 100
    end
    it "subtracts donations appropriately" do
      Factory(:donation, :pitch => @pitch, :amount => 20, :status => 'paid')
      @pitch.funding_needed.should == 80
    end
    it "is the initial amount when a pitch is unapproved" do
      @pitch.update_attribute(:status, 'unapproved')
      @pitch.funding_needed.should == 100
    end
    it "is 0 when a pitch is accepted" do
      @pitch.accept!
      @pitch.funding_needed.should == 0
    end
    it "is 0 when a pitch is fully_funded" do
      @pitch.fund!
      @pitch.funding_needed.should == 0
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
      pitch = active_pitch(:requested_amount => 100)
      pitch.accept!
      pitch.fully_funded?.should be_true
    end
  end

  describe "half_funded?" do
    before do
      @pitch = active_pitch(:requested_amount => 100)
    end
    it "should return true if the pitch state is accepted" do
      @pitch.accept!
      @pitch.should be_half_funded
    end
    it "should return true if the pitch state is funded" do
      @pitch.fund!
      @pitch.should be_half_funded
    end
    it "should return false if the total donations are 50% or less of the requested amount" do
      @pitch.donations.stub!(:paid).and_return([stub('donation', :amount => 50)])
      @pitch.half_funded?.should be_false
    end
    it "should return true if the total donations are more than 50%" do
      @pitch.donations.stub!(:paid).and_return([stub('donation', :amount => 60)])
      @pitch.half_funded?.should be_true
    end
  end

  describe "half_fund!" do
    before do
      @user = Factory(:organization)
      @pitch = Factory(:pitch, :requested_amount => 100)
    end

    it "should create a donation for half the requested amount" do
      @pitch.donations.should_receive(:create).with(:amount => 50, :user => @user)
      @pitch.half_fund!(@user)
    end
    it "should delete other unpaid donations from the current user" do
      other_donation = Factory(:donation, :pitch => @pitch, :user => @user)
      unpaid = stub('named scope', :for_user => [other_donation])
      @pitch.donations.should_receive(:unpaid).and_return(unpaid)
      other_donation.should_receive(:destroy).and_return(true)
      @pitch.half_fund!(@user)
    end
  end

  describe "fully_fund!" do
    before do
      @user = Factory(:organization)
      @pitch = Factory(:pitch, :requested_amount => 100)
    end
    it "should create a donation for the requested_amount" do
      @pitch.donations.should_receive(:create).with(:amount => @pitch.requested_amount, :user => @user)
      @pitch.fully_fund!(@user)
    end
    it "should delete other unpaid donations from the current user" do
      other_donation = Factory(:donation, :pitch => @pitch, :user => @user)
      unpaid = stub('named scope', :for_user => [other_donation])
      @pitch.donations.should_receive(:unpaid).and_return(unpaid)
      other_donation.should_receive(:destroy).and_return(true)
      @pitch.fully_fund!(@user)
    end
  end

  describe "donations.for_user" do
    it "should not return users other than the one requested" do
      user = Factory(:user)
      pitch = active_pitch(:user => Factory(:user), :requested_amount => 100)
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
        p.user_can_donate_more?(Factory(:citizen), 1000).should be_false
      end

      it "can donate more, as long as funds plus attempted donation are less than requested amount" do
        p = active_pitch(:requested_amount => 100)
        p.user_can_donate_more?(Factory(:citizen), 20).should be_true
      end

      it "can donate more at all (passing zero as second arg)" do
        u = Factory(:user)
        p = Factory(:pitch, :requested_amount => 100, :status => 'active')
        d = Factory(:donation, :pitch => p, :user => u, :amount => 10)
        p.user_can_donate_more?(u, 0).should be_true
        p.user_can_donate_more?(u, 11).should be_true
      end

      it "allows a news organization to donate the requested amount" do
        p = active_pitch(:requested_amount => 100)
        Factory(:donation, :pitch => p, :user => Factory(:user), :amount => 10, :status => "paid")
        p.user_can_donate_more?(Factory(:organization), 100).should be_true
      end
    end

    describe "as a citizen or reporter" do
      before(:each) do
        @user = Factory(:user)
        @pitch = active_pitch(:user => Factory(:user), :requested_amount => 100)
      end

      it "allows donation if the user has no existing donations" do
        p = active_pitch(:requested_amount => 100)
        p.user_can_donate_more?(Factory(:user), 10)
      end

      it "return false if the user's total donations + total trying to donate is > 20% of the requested amount" do
        Factory(:donation, :pitch => @pitch, :user => @user, :amount => 10, :status => 'paid')
        Factory(:donation, :pitch => @pitch, :user => @user, :amount => 10, :status => 'paid')
        @pitch.reload
        @pitch.user_can_donate_more?(@user, 10).should be_false
      end

      it "return true if the user's total donations + total trying to donate is = 20% of the requested amount" do
        Factory(:donation, :pitch => @pitch, :user => @user, :amount => 5)
        Factory(:donation, :pitch => @pitch, :user => @user, :amount => 5)
        @pitch.reload
        @pitch.user_can_donate_more?(@user, 10).should be_true
      end

      it "return true if the user's total donations + total trying to donate is < 20% of the requested amount" do
        Factory(:donation, :pitch => @pitch, :user => @user, :amount => 3)
        Factory(:donation, :pitch => @pitch, :user => @user, :amount => 5)
        @pitch.reload
        @pitch.user_can_donate_more?(@user, 10).should be_true
      end
    end

    describe "as a news organization" do
      it "return true even if more than 20% because we are an organization" do
        organization = Factory(:organization)
        pitch = Factory(:pitch, :user => Factory(:user), :requested_amount => 100)
        pitch.user_can_donate_more?(organization, 100).should be_true
      end
    end

    describe "many users" do
      it "can donate and push a pitch to fully funded" do
        pitch = active_pitch(:requested_amount => 50)
        5.times do
          donation = Donation.create(:pitch => pitch, :user => Factory(:user, :type => 'Organization'), :amount => 10)
          donation.should be_valid
          donation.pay!
        end
        pitch.reload.should be_funded
      end
    end
  end

  describe "creating" do
    it "is creatable by reporter" do
      Pitch.createable_by?(Factory(:reporter)).should be
    end
    
    it "is creatable by organization" do
      Pitch.createable_by?(Factory(:organization)).should be
    end

    it "is not creatable by user" do
      Pitch.createable_by?(Factory(:user)).should_not be_true
    end

    it "is not creatable if not logged in" do
      Pitch.createable_by?(nil).should_not be
    end
  end

  describe "show_support!" do
    before do
      @pitch = Factory(:pitch)
      @organization = Factory(:organization)
    end
    it "add the organization to the pitch's supporting organizations" do
      @pitch.show_support!(@organization)
      @pitch.supporting_organizations.should include(@organization)
    end

    it "doesn't add the same organization to the pitch's supporting organizations twice" do
      @pitch.show_support!(@organization)
      lambda{@pitch.show_support!(@organization)}.should change(@pitch.supporting_organizations, :size).by(0)
    end

  end

  describe "apply to contribute" do
    before do
      @pitch = Factory(:pitch)
      @reporter = Factory(:reporter)
    end
    it "returns false if no user is passed in" do
      @pitch.apply_to_contribute(nil).should be_false
    end
    it "adds the user to the pitch's contributors" do
      lambda{@pitch.apply_to_contribute(@reporter)}.should change(@pitch.contributor_applicants, :size).by(1)
    end
    it "only adds the user once" do
      @pitch.stub!(:contributors).and_return([@reporter])
      lambda{@pitch.apply_to_contribute(@reporter)}.should change(@pitch.contributor_applicants, :size).by(0)
    end
    it "sends an email to admin" do
      Mailer.should_receive(:deliver_admin_reporting_team_notification)
      @pitch.apply_to_contribute(Factory(:citizen))
    end
    it "sends an email to the reporter" do
      Mailer.should_receive(:deliver_reporter_reporting_team_notification)
      @pitch.apply_to_contribute(Factory(:citizen))
    end
    it "sends an email to the applicant" do
      Mailer.should_receive(:deliver_applied_reporting_team_notification)
      @pitch.apply_to_contribute(Factory(:citizen))
    end
  end

  describe "#approve_blogger!" do
    before do
      @pitch = active_pitch
      @reporter = Factory(:reporter)
      Factory(:contributor_application, :user => @reporter, :pitch => @pitch, :approved => false)
    end
    it "doesn't raise an error if no user is passed in" do
      lambda{@pitch.approve_blogger!(nil)}.should_not raise_error
    end
    it "approves the user's contributor application" do
      lambda{@pitch.approve_blogger!(@reporter.id)}.should change(@pitch.contributors, :size).by(1)
    end
    it "only adds the user once" do
      @pitch.stub!(:contributors).and_return([@reporter])
      lambda{@pitch.approve_blogger!(@reporter.id)}.should change(@pitch.contributors, :size).by(0)
    end
    it "emails the user" do
      Mailer.should_receive(:deliver_approved_reporting_team_notification)
      @pitch.approve_blogger!(@reporter.id)
    end
  end

  describe "#unapprove_blogger!" do
    before do
      @pitch = active_pitch
      @reporter = Factory(:reporter)
      Factory(:contributor_application, :user => @reporter, :pitch => @pitch, :approved => true)
    end
    it "doesn't raise an error if no user is passed in" do
      lambda{@pitch.unapprove_blogger!(nil)}.should_not raise_error
    end
    it "unapproves the pitch's contributors" do
      lambda{@pitch.unapprove_blogger!(@reporter.id)}.should change(@pitch.contributors, :size).by(-1)
    end
  end

  describe "contributor scopes" do
    before do
      @pitch = active_pitch
      Factory(:contributor_application, :pitch => @pitch, :approved => true)
      Factory(:contributor_application, :pitch => @pitch, :approved => false)
    end
    describe "contributors" do
      it "should only contain contributors with approved applications" do
        @pitch.contributors.all? {|c| ContributorApplication.find_by_user_id_and_pitch_id(c.id, @pitch.id).approved? }.should be_true
      end
    end
  end

  describe "featuring" do

    describe "feature!" do
      it "should set the pitch to featured" do
        pitch = Factory(:pitch)
        pitch.feature!
        pitch.reload.feature.should be_true
      end
    end

    describe "unfeature!" do
      it "should set the pitch to unfeatured" do
        pitch = Factory(:pitch)
        pitch.unfeature!
        pitch.reload.feature.should be_false
      end
    end

    describe "featureable_by?" do
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

  describe "to support STI" do
    it "descends from NewItem" do
      Pitch.ancestors.include?(NewsItem)
    end
  end

  describe "a pitch with donations" do
    before(:each) do
      @pitch = active_pitch
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

    describe "becomes fully funded (by way of fund!)" do
      it "when paid donations equal requested amount" do
        p = active_pitch(:requested_amount => 50)
        5.times do
          donation = Factory(:donation, :pitch => p, :user => Factory(:user), :amount => 10)
          donation.should be_valid
          donation.pay!
        end
        p.should be_valid
        p.reload.should be_funded
      end

      it "should trigger fund events when it's funded" do
        p = active_pitch(:requested_amount => 100)
        p.should_receive(:do_fund_events)
        p.fund!
      end
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

  describe "Being funded" do
    describe "via fund!" do
      it "creates a story from an active pitch" do
        p = active_pitch
        p.fund!
        p.story.should_not be_nil
      end
      it "creates a story from an unapproved pitch" do
        p = Factory(:pitch)
        p.fund!
        p.story.should_not be_nil
      end
    end
    describe "via accept!" do
      it "creates a story from an active pitch" do
        p = active_pitch
        p.accept!
        p.story.should_not be_nil
      end
      it "creates a story from an unapproved pitch" do
        p = Factory(:pitch)
        p.accept!
        p.story.should_not be_nil
      end
    end
  end

  describe "with_sort" do
    it "should return only pitches without stories" do
      named_scope = stub("a named scope")
      browsable = stub('browsable')
      Pitch.stub!(:browsable).and_return(browsable)
      browsable.should_receive(:without_a_story).and_return(named_scope)
      named_scope.should_receive(:desc)
      Pitch.with_sort
    end
    it "should return only approved pitches" do
      Pitch.should_receive(:browsable).and_return(named_scope = stub("a named scope"))
      named_scope.stub!(:without_a_story).and_return(stub('named scope', :desc => []))
      Pitch.with_sort
    end
  end

  describe ".featured_by_network" do
    before do
      @pitches = [@pitch]
      @networks = [stub('network', :featured_pitches => @pitches)]
      Network.stub!(:with_pitches).and_return(@networks)
    end
    context "when no network is supplied" do
      it "should get the pitches pitches by network" do
        Pitch.featured_by_network.should == @pitches
      end
    end
    context "when a network is supplied" do
      before do
        @network = stub('network', :id => 42)
      end
      it "should get featured pitches for that network" do
        @network.should_receive(:featured_pitches)
        Pitch.featured_by_network(@network)
      end
    end
  end

  describe "#approvable_by?" do
    before do
      @pitch = Factory(:pitch)
      @active_pitch = active_pitch
      @admin = Factory(:admin)
    end
    it "should return true if admin and pitch.unapproved?" do
      @pitch.approvable_by?(@admin).should be_true
    end
    it "should return true if admin and pitch.active?" do
      @active_pitch.approvable_by?(@admin).should be_true
    end
    it "should return false if admin and pitch.funded?" do
      @active_pitch.fund!
      @active_pitch.approvable_by?(@admin).should be_false
    end
    it "should return false if admin and pitch.accepted?" do
      @active_pitch.accept!
      @active_pitch.approvable_by?(@admin).should be_false
    end
    it "should return false if the passed in user is nil" do
      @pitch.approvable_by?(nil).should be_false
    end
    it "should return false if the passed in user is not an admin" do
      editor = Factory(:reporter)
      @pitch.approvable_by?(editor).should be_false
    end
  end

  describe "#postable_by?" do
    before do
      @pitch = active_pitch
    end
    it "should return true if the passed in user is the reporter" do
      @pitch.postable_by?(@pitch.user).should be_true
    end
    it "should return true if the passed in user is an admin" do
      @pitch.postable_by?(Factory(:admin)).should be_true
    end
    it "should return false otherwise" do
      @pitch.postable_by?(Factory(:user)).should be_false
    end
    it "should return false if the passed in user is nil" do
      @pitch.postable_by?(nil).should be_false
    end
    it "should return true if the passed in user is a contributor" do
      user = Factory(:citizen)
      @pitch.stub!(:contributors).and_return([user])
      @pitch.should be_postable_by(user)
    end
    it "should return true if the passed in user is the peer review editor" do
      editor = Factory(:reporter)
      @pitch.fact_checker = editor
      @pitch.postable_by?(editor).should be_true
    end
  end

  describe "donating_groups" do
    before do
      @pitch = active_pitch
      @group1 = Factory(:group)
      Factory(:donation, :group => @group1, :pitch => @pitch, :amount => 20, :status => 'paid')
      Factory(:donation, :group => @group1, :pitch => @pitch, :amount => 30, :status => 'paid')
      @group2 = Factory(:group)
    end
    it "should not include duplicates" do
      @pitch.donating_groups.size.should == 1
    end
    it "should list only groups with paid donations" do
      @pitch.donating_groups.should_not include(@group2)
    end
    it "should not include nil groups" do
      Factory(:donation, :group => nil, :pitch => @pitch, :amount => 45, :status => 'paid')
      @pitch.donating_groups.should_not include(nil)
    end
  end

  describe "Remove blog posts with pitches" do
    it "posts are dependent destroy" do
      pitch = active_pitch
      post = stub('post')
      pitch.stub!(:posts).and_return([post])
      post.should_receive(:destroy)
      pitch.destroy
    end
  end
end

