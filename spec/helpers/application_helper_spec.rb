require File.dirname(__FILE__) + '/../spec_helper'

describe ApplicationHelper do
  include ApplicationHelper

  it "should give us the current balance" do
    user = Factory(:user)
    Factory(:donation, :user => user, :amount => 10)
    stub!(:current_user).and_return(user)
    current_balance.should == 10.0
  end

  it "should add correctly" do
    user = Factory(:user)
    Factory(:donation, :user => user, :amount => 10)
    Factory(:donation, :user => user, :amount => 10)
    stub!(:current_user).and_return(user)
    current_balance.should == 20.0
  end

  it "should return 0 when there are no unpaid donations" do
    user = Factory(:user)
    stub!(:current_user).and_return(user)
    current_balance.should == 0
  end

  it "should display credits only message when no updaid donations but there are credits" do
    user = Factory(:user)
    stub!(:current_user).and_return(user)
    Factory(:credit, :amount => 25, :user => user)
    header_display_message.should =~ /You have \$25.00 in credit/
  end

  it "should display credits and donations message when have both" do
    user = Factory(:user)
    stub!(:current_user).and_return(user)
    Factory(:credit, :amount => 25, :user => user)
    Factory(:donation, :amount => 25, :user => user)
    header_display_message.should =~ /credits to use toward your donations/
  end

  it "should display donations message when only have donations and no credits" do
    user = Factory(:user)
    stub!(:current_user).and_return(user)
    Factory(:donation, :amount => 25, :user => user)
    header_display_message.should =~ /to fund your donations/
   end

  describe "#networks_for_select" do
    it "should return the default value first" do
      networks_for_select.should include(['Select A Network', ''])
    end

    it "should get all Networks" do
      Network.should_receive(:all).and_return([])
      networks_for_select
    end

    it "should return an array with name, id pairs" do
      Network.stub!(:all).and_return([Factory(:network, :display_name => 'network-name', :id => 17)])
      networks_for_select.should include(['network-name', 17])
    end
  end

  describe "#categories_for_select" do
    it "should return the default value first" do
      categories_for_select(User.new).should == ['Sub-network', '']
    end

    it "should return categories for the given network" do
      network = Factory(:network)
      network.categories = [Factory(:category)]
      user = Factory(:user, :network => network)
      categories_for_select(user).should include([network.categories.first.name, network.categories.first.id])
    end

    it "should fail gracefully given an object with no network" do
      lambda do
        categories_for_select(stub('user', :network => nil))
      end.should_not raise_error
    end
  end

  describe "#current_network_id" do
    it "should return @current_network.id if it exists" do
      instance_variable_set(:@current_network, Factory(:network, :id => 17))
      current_network_id.should == 17
    end
    it "should return nil otherwise" do
      current_network_id.should be_nil
    end
  end

  describe "#available_pitches_for" do
    before do
      @affiliation = Factory(:affiliation)
      @other_pitch = active_pitch
      reporter = Factory(:reporter)
      reporter.stub!(:pitches).and_return([@affiliation.pitch, @other_pitch])
      stub!(:current_user).and_return(reporter)
    end
    it "should return pitches that aren't affiliated with a given tip" do
      available_pitches_for(@affiliation.tip).should include([@other_pitch.headline, @other_pitch.id])
    end
    it "should not return pitches that are already affiliated with a given tip" do
      available_pitches_for(@affiliation.tip).should_not include([@affiliation.pitch.headline, @affiliation.pitch.id])
    end
  end

  describe "fact_checkers_for" do
    before do
      @applicants = [Factory(:reporter), Factory(:citizen)]
      @interested_users = [Factory(:citizen), Factory(:reporter)]
      @uninterested_users = [Factory(:citizen)]
      User.stub!(:fact_checkers).and_return(@interested_users)
      @pitch = active_pitch
      @pitch.stub!(:contributor_applicants).and_return(@applicants)
    end
    it "should have two option groups" do
      fact_checkers_for(@pitch).should have_tag('optgroup[label=?]', 'Pitch Applicants')
      fact_checkers_for(@pitch).should have_tag('optgroup[label=?]', 'General Interest')
    end
    it "should include all the applicants for the pitch" do
      fact_checkers = fact_checkers_for(@pitch)
      @applicants.each do |applicant|
        fact_checkers.should have_tag('option[value=?]', applicant.id)
      end
    end
    it "should include all users who have shown an interest in fact checking" do
      fact_checkers = fact_checkers_for(@pitch)
      @interested_users.each do |user|
        fact_checkers.should have_tag('option[value=?]', user.id)
      end
    end
    it "should include all other users in a third group" do
      fact_checkers_for(@pitch).should have_tag('optgroup[label=?]', 'All Users') do
        with_tag('option[value=?]', @uninterested_users.first.id)
      end
    end
    it "should display 'No applicants' when nobody has applied to fact-check a pitch" do
      @pitch.stub!(:contributor_applicants).and_return([])
      fact_checkers_for(@pitch).should have_tag('option', 'No applicants')
    end
  end

  describe "facebox_login_link_to" do
    before do
      stub!(:current_user).and_return(nil)
      stub!(:store_location)
      @pitch = active_pitch
    end
    it "returns a regular link_to if user is logged in" do
      stub!(:current_user).and_return(Factory.build(:reporter))
      facebox_login_link_to("some text", apply_to_contribute_pitch_path(@pitch), :title => 'Join the team').should == link_to("some text", apply_to_contribute_pitch_path(@pitch), :title => 'Join the team')
    end
    it "returns a link to login with facebox if user is not logged in" do
      stub!(:current_user).and_return(nil)
      facebox_login_link_to("some text", apply_to_contribute_pitch_path(@pitch), :title => 'Join the team').should have_tag("a[class='authbox'][href*=?]", new_session_path)
    end
  end
end
