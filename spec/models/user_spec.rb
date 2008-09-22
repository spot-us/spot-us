require File.dirname(__FILE__) + '/../spec_helper'

# Be sure to include AuthenticatedTestHelper in spec/spec_helper.rb instead.
# Then, you can remove it from this and the functional test.
include AuthenticatedTestHelper

describe User do
  fixtures :users

  describe 'being created' do
    before do
      @user = nil
      @creating_user = lambda do
        @user = create_user
        violated "#{@user.errors.full_messages.to_sentence}" if @user.new_record?
      end
    end
    
    it 'increments User#count' do
      @creating_user.should change(User, :count).by(1)
    end
  end

  it 'generates password on create' do
    user = create_user(:password => nil)
    violated "#{user.errors.full_messages.to_sentence}" if user.new_record?
    user.password.should_not be_nil
    user.password.size.should == 6
    User.authenticate(user.email, user.password).should == 
      User.find(user.to_param)
  end

  it 'requires password confirmation on update' do
    user = create_user
    user.update_attributes(:password => 'new password', :password_confirmation => nil)
    user.should_not be_valid
    user.errors.on(:password_confirmation).should_not be_nil
  end

  it 'requires email' do
    lambda do
      u = create_user(:email => nil)
      u.errors.on(:email).should_not be_nil
    end.should_not change(User, :count)
  end

  %w(Citizen Reporter Organization).each do |user_type|
    it "should allow a type of #{user_type}" do
      user = create_user
      user.type = user_type
      user.save
      violated "#{user.errors.full_messages.to_sentence}" if user.new_record?
    end
  end

  it "should not allow a type of BusDriver" do
    user = create_user
    user.type = 'BusDriver'
    user.valid?
    user.should_not be_valid
    user.should have(1).error_on(:type)
  end

  it "should require a type" do
    user = create_user
    user.type = nil
    user.valid?
    user.should_not be_valid
    user.should have(1).error_on(:type)
  end

  it 'resets password' do
    users(:quentin).update_attributes(:password => 'new password', :password_confirmation => 'new password')
    User.authenticate('quentin@example.com', 'new password').should == users(:quentin)
  end

  it 'does not rehash password' do
    users(:quentin).update_attributes(:email => 'quentin2@example.com')
    User.authenticate('quentin2@example.com', 'test').should == users(:quentin)
  end

  it "requires first name" do
    user = create_user(:first_name => nil)
    user.should_not be_valid
    user.should have(1).error_on(:first_name)
  end

  it "requires last name" do
    user = create_user(:last_name => nil)
    user.should_not be_valid
    user.should have(1).error_on(:last_name)
  end

  it 'authenticates user' do
    User.authenticate('quentin@example.com', 'test').should == users(:quentin)
  end

  it 'sets remember token' do
    users(:quentin).remember_me
    users(:quentin).remember_token.should_not be_nil
    users(:quentin).remember_token_expires_at.should_not be_nil
  end

  it 'unsets remember token' do
    users(:quentin).remember_me
    users(:quentin).remember_token.should_not be_nil
    users(:quentin).forget_me
    users(:quentin).remember_token.should be_nil
  end

  it 'remembers me for one week' do
    before = 1.week.from_now.utc
    users(:quentin).remember_me_for 1.week
    after = 1.week.from_now.utc
    users(:quentin).remember_token.should_not be_nil
    users(:quentin).remember_token_expires_at.should_not be_nil
    users(:quentin).remember_token_expires_at.between?(before, after).should be_true
  end

  it 'remembers me until one week' do
    time = 1.week.from_now.utc
    users(:quentin).remember_me_until time
    users(:quentin).remember_token.should_not be_nil
    users(:quentin).remember_token_expires_at.should_not be_nil
    users(:quentin).remember_token_expires_at.should == time
  end

  it 'remembers me default two weeks' do
    before = 2.weeks.from_now.utc
    users(:quentin).remember_me
    after = 2.weeks.from_now.utc
    users(:quentin).remember_token.should_not be_nil
    users(:quentin).remember_token_expires_at.should_not be_nil
    users(:quentin).remember_token_expires_at.between?(before, after).should be_true
  end

protected
  def create_user(options = {})
    record = User.new({ :email      => 'quire@example.com',
                        :first_name => 'Quire',
                        :last_name  => 'User' }.merge(options))
    record.type = 'Citizen'
    record.save
    record
  end
end
