require File.dirname(__FILE__) + '/../spec_helper'

# Be sure to include AuthenticatedTestHelper in spec/spec_helper.rb instead.
# Then, you can remove it from this and the functional test.
include AuthenticatedTestHelper

describe User do
  it { Factory(:citizen).should belong_to(:network) }
  it { Factory(:citizen).should belong_to(:category) }
  it { Factory(:citizen).should have_many(:donations) }
  it { Factory(:citizen).should have_many(:tips) }
  it { Factory(:citizen).should have_many(:pitches) }
  it { Factory(:citizen).should have_many(:posts) }
  it { Factory(:citizen).should have_many(:pledges) }
  it { Factory(:citizen).should have_many(:jobs) }
  it { Factory(:citizen).should have_many(:samples) }
  it { Factory(:citizen).should have_many(:credits) }
  table_has_columns(User, :boolean,  "notify_tips")
  table_has_columns(User, :boolean,  "notify_pitches")
  table_has_columns(User, :boolean,  "notify_stories")
  table_has_columns(User, :boolean,  "notify_spotus_news")

  before do
    Network.create!(:name => 'sfbay', :display_name => 'Bay Area')
  end

  describe "creating" do
    it "is creatable by guest" do
      User.createable_by?(nil).should be
    end

    it "should set default opt-in values" do
      User.opt_in_defaults.each do |key,value| 
        User.new.send(key).should == value
      end
    end

    it "should only allow valid creatable types" do
      lambda{ User.new(:type => "Admin") }.should raise_error(ArgumentError)
    end

    it "should not generate a password" do
      @user = User.new
      @user.should_not_receive(:generate_password)
      @user.save
    end

  end

  describe "total_credits" do
    it "should return the total of credits" do
      user = Factory(:citizen)
      Factory(:credit, :amount => 25, :user => user)
      Factory(:credit, :amount => 25, :user => user)
      user.total_credits.should == 50.0
    end

    it "should return credits when there are negative credits" do
      user = Factory(:citizen)
      Factory(:credit, :amount => 25, :user => user)
      Factory(:credit, :amount => -25, :user => user)
      user.total_credits.should == 0
    end
  end

  describe "generate_csv" do
    it "should return a comma-separated list" do
      user = Factory(:citizen, :type => "Citizen", :email => 'happy@happy.com',
                     :first_name => "Desi", :last_name => "McAdam",
                     :notify_tips => "true", :notify_pitches => "true",
                     :notify_stories => "true", :notify_spotus_news => "true",
                     :fact_check_interest => "true", :network => Network.first  )
      User.generate_csv.split("\n").should include("Citizen,happy@happy.com,Desi,McAdam,#{Network.first.name},true,true,true,true,true")
    end
  end

  describe "topics_params=" do
    it "should create topic associations" do
      t = Topic.create(:name => "Topic 1")
      u = Factory(:citizen)
      u.topics_params=([t.id])
      u.reload
      u.topics.should == [t]
    end

    it "should handle record not found gracefully" do
      u = Factory(:citizen)
      u.topics_params=([nil])
      u.reload
      u.topics.should == []
    end

    it "should not add duplicate topics" do
      t = Topic.create(:name => "Topic 1")
      u = Factory(:citizen)
      u.topics_params=([t.id])
      u.reload
      u.topics.should == [t]
      u.topics_params=([t.id])
      u.reload
      u.topics.size.should == 1
      u.topics.should == [t]
    end
  end

  describe "editing" do
    before(:each) do
      @user = Factory(:citizen)
    end

    it "is editable by its self" do
      @user.editable_by?(@user).should be_true
    end

    it "is not editable by a stranger" do
      @user.editable_by?(Factory(:citizen)).should_not be_true
    end

    it "is not editable if not logged in" do
      @user.editable_by?(nil).should_not be_true
    end

    it "should require a network" do
      @user.update_attribute(:network, nil)
      @user.should have(1).error_on(:network)
    end
  end

  it "returns the amount pledged on amount_pledged_to(tip)" do
    user = Factory(:citizen)
    pledge1 = Factory(:pledge, :user => user, :amount => 1)
    pledge2 = Factory(:pledge, :user => user, :amount => 3)
    user.reload
    user.amount_pledged_to(pledge1.tip).should == pledge1.amount
    user.amount_pledged_to(pledge2.tip).should == pledge2.amount
  end

  it "returns the amount donated on amount_donated_to(pitch)" do
    user = Factory(:citizen)
    donation1 = Factory(:donation, :user => user, :amount => 1)
    donation2 = Factory(:donation, :user => user, :amount => 3)
    [donation1,donation2].each do |donation|
      donation.pay!
    end
    user.reload
    user.amount_donated_to(donation1.pitch).should == donation1.amount
    user.amount_donated_to(donation2.pitch).should == donation2.amount
  end

  describe "signup notification emails" do
    it "sends email to citizen after activation" do
      c = Factory(:citizen)
      Mailer.should_receive(:deliver_citizen_signup_notification)
      c.activate!
    end

    it "sends email to news org after signup" do
      Mailer.should_receive(:deliver_organization_signup_notification)
      Factory(:organization)
    end

    it "sends email to reporter after activation" do
      Mailer.should_receive(:deliver_reporter_signup_notification)
      Factory(:reporter).activate!
    end

    it "doesn't send on save" do
      user = Factory(:citizen)
      Mailer.should_not_receive(:deliver_signup_notification).with(user)
      user.save
    end
  end

  describe 'being created' do
    before do
      @user = nil
      @creating_user = lambda do
        @user = Factory(:citizen)
        violated "#{@user.errors.full_messages.to_sentence}" if @user.new_record?
      end
    end

    it 'increments User#count' do
      @creating_user.should change(User, :count).by(1)
    end
  end

  it "should set status to unapproved when user is news org" do
    user = Factory(:organization)
    user.status.should == "needs_approval"
  end

  it 'requires password confirmation on update' do
    user = Factory(:citizen)
    user.update_attributes(:password => 'new password', :password_confirmation => nil)
    user.should_not be_valid
    user.errors.on(:password_confirmation).should_not be_nil
  end

  it "doesn't require password_confirmation on save" do
    user = Factory :user
    user.email = random_email_address
    user.save.should be_true
  end

  it 'requires email' do
    user = Factory.build(:user, :email => nil)
    user.should_not be_valid
    user.errors.on(:email).should_not be_nil
  end

  %w(Citizen Reporter Organization).each do |user_type|
    it "should allow a type of #{user_type}" do
      user = Factory(:citizen, :type => user_type)
      violated "#{user.errors.full_messages.to_sentence}" if user.new_record?
    end
  end

  it "should not allow a type of BusDriver" do
    user = Factory.build(:user, :type => 'BusDriver')
    user.should_not be_valid
    user.should have(1).error_on(:type)
  end

  it "should require a type" do
    user = Factory.build(:user, :type => nil)
    user.should_not be_valid
    user.should have(1).error_on(:type)
  end

  describe "after being created" do
    before do
      @password = 'test'
      @user = Factory(:citizen, :email    => 'user@example.com',
                                :password => @password,
                                :password_confirmation => @password)
      @user.activate!
    end

    it 'does not rehash password' do
      @user.update_attributes!(:email => 'quentin2@example.com')
      User.authenticate('quentin2@example.com', @password).should == @user
    end

    it "does not authenticate if the user is not activated" do
      @user.update_attribute(:activation_code, 'foo')
      User.authenticate(@user.email, @password).should be_nil
    end

    it 'is found by correct authentication' do
      User.authenticate('user@example.com', @password).should == @user
    end

    it 'sets remember token' do
      @user.remember_me
      @user.remember_token.should_not be_nil
      @user.remember_token_expires_at.should_not be_nil
    end

    it 'unsets remember token' do
      @user.remember_me
      @user.remember_token.should_not be_nil
      @user.forget_me
      @user.remember_token.should be_nil
    end

    it 'remembers me for one week' do
      before = 1.week.from_now.utc
      @user.remember_me_for 1.week
      after = 1.week.from_now.utc
      @user.remember_token.should_not be_nil
      @user.remember_token_expires_at.should_not be_nil
      @user.remember_token_expires_at.between?(before, after).should be_true
    end

    it 'remembers me until one week' do
      time = 1.week.from_now.utc
      @user.remember_me_until time
      @user.remember_token.should_not be_nil
      @user.remember_token_expires_at.should_not be_nil
      @user.remember_token_expires_at.should == time
    end

    it 'remembers me default two weeks' do
      before = 2.weeks.from_now.utc
      @user.remember_me
      after = 2.weeks.from_now.utc
      @user.remember_token.should_not be_nil
      @user.remember_token_expires_at.should_not be_nil
      @user.remember_token_expires_at.between?(before, after).should be_true
    end

    it "resets the password" do
      @old_crypted_password = @user.crypted_password
      @user.reset_password!
      @user.reload
      @user.crypted_password.should_not == @old_crypted_password
    end

    it "sends a password reset email" do
      Mailer.should_receive(:deliver_password_reset_notification).with(@user).once
      @user.reset_password!
    end

    it "should set the default network to the first network" do
      user = User.new
      user.valid?
      user.network.should == Network.first
    end
  end

  describe "activation" do
    before do
      Mailer.stub!(:deliver_activation_email)
      @user = Citizen.new(Factory.attributes_for(:citizen))
    end

    it "should send an activation email" do
      @user.should_receive(:deliver_activation_email)
      @user.save
    end

    it "should clear the activation code on activate!" do
      @user.valid?
      @user.activate!
      @user.activation_code.should be_nil
    end

    it "should clear the activation code on approved organization's activate!" do
      organization = Factory(:organization)
      organization.valid?
      organization.approve!
      organization.activate!
      organization.activation_code.should be_nil
    end

    it "should return true for activated users on activated?" do
      @user.valid?
      @user.activate!
      @user.should be_activated
    end

    it "should generate an activation code" do
      @user.save
      @user.activation_code.should_not be_nil
    end
  end

  it "should require acceptance of terms of service" do
    user = Factory.build(:user, :terms_of_service => '0')
    user.should_not be_valid
    user.should have(1).error_on(:terms_of_service)
  end

  it "requires first name" do
    user = Factory.build(:user, :first_name => nil)
    user.should_not be_valid
    user.should have(1).error_on(:first_name)
  end

  it "requires last name" do
    user = Factory.build(:user, :last_name => nil)
    user.should_not be_valid
    user.should have(1).error_on(:last_name)
  end

  it "should have a photo attachment" do
    Factory(:citizen).photo.should be_instance_of(Paperclip::Attachment)
  end

  it "should be valid for each network" do
    user = Factory(:citizen)
    Network.all.each do |network|
      user.network = network
      user.should be_valid
    end
  end

  it "should combine the first and last name for full name" do
    user = Factory(:citizen, :first_name => 'First', :last_name => 'Second')
    user.full_name.should == 'First Second'
  end

  it "should allow a url starting with http" do
    user = Factory.build(:user, :website => "http://something")
    user.should be_valid
  end

  it "should not allow a url that does not start with http" do
    user = Factory.build(:user, :website => "bob")
    user.should_not be_valid
    user.should have(1).error_on(:website)
  end

  it "should allow for the website to be blank" do
    user = Factory.build(:user, :website => nil)
    user.should be_valid
  end

  describe "with a donation for a pitch" do
    before do
      @user = Factory(:citizen)
      @pitch = active_pitch(:requested_amount => 100)
    end

    it "should know that the user has donated to that pitch" do
      donation = Factory(:donation, :user => @user, :pitch => @pitch)
      @user.has_donation_for?(@pitch).should be_true
    end

    it "should return the unpaid sum for donations" do
      donation = Factory(:donation, :user => @user, :pitch => @pitch)
      @user.unpaid_donations_sum.should == donation.amount
    end

    it "should allow the user to donate to a pitch after donating < 20%" do
      @user.can_donate_to?(@pitch).should be_true
    end

    it "should know that the user has a paid donation" do
      donation = Factory(:donation, :user => @user, :pitch => @pitch)
      donation.pay!
      @user.has_donated_to?(@pitch).should be_true
    end

    it "should not allow the user to donate to a pitch after donating 20%" do
      user = Factory(:citizen)
      pitch = active_pitch(:requested_amount => 100)
      donation = Factory(:donation, :user => user, :pitch => pitch, :amount => 20)
      user.can_donate_to?(pitch).should be_false
    end

    it "should return the max donation amount" do
      user = Factory(:citizen)
      pitch = active_pitch(:requested_amount => 100)
      donation = Factory(:donation, :user => user, :pitch => pitch, :amount => 10)
      user.max_donation_for(pitch).should == 10
    end
  end

  describe "without a donation for a pitch" do
    before do
      @user = Factory(:citizen)
      if @user.donations.detect {|donation| donation.pitch == @pitch }
        violated "the user should not have any donations for the pitch"
      end

      @pitch = active_pitch
    end

    it "should know that the user hasn't donated to that pitch" do
      @user.has_donation_for?(@pitch).should be_false
    end
  end

  describe "with spotus donations" do
    before do
      @user = Factory(:citizen)
      @spotus_donation_one = Factory(:spotus_donation, :purchase => Factory(:purchase), :user => @user)
      @spotus_donation_two = Factory(:spotus_donation, :purchase => nil, :user => @user)
    end

    it "should return the current unpaid spotus donation" do
      @user.current_spotus_donation.should == @spotus_donation_two
    end

    it "should have spotus donations" do
      @user.has_spotus_donation?.should be_true
    end

    it "should have an unpaid spotus donation" do
      @user.unpaid_spotus_donation.should == @spotus_donation_two
    end

    it "should return the sum of paid spotus donations" do
      @user.paid_spotus_donations_sum.should == @spotus_donation_one.amount
    end
  end

  describe "without any spotus donations" do
    before do
      @user = Factory(:citizen)
    end

    it "should return a new record for current_spotus_donation" do
      @user.current_spotus_donation.should be_a_new_record
    end

    it "should return a SpotusDonation for current_spotus_donation" do
      @user.current_spotus_donation.should be_a_kind_of(SpotusDonation)
    end

    it "should not have spotus donations" do
      @user.has_spotus_donation?.should be_false
    end

    it "should return 0 for the sum of the paid spotus donations" do
      @user.paid_spotus_donations_sum.should == 0
    end
  end
end
