require File.dirname(__FILE__) + "/../../../spec_helper"

describe 'myspot/pledges/index' do
  before do
    @user = Factory(:user)
    @tips = [Factory(:tip), Factory(:tip)]
    @pledges = @tips.collect {|tip| Factory(:pledge, :user => @user, :tip => tip) }
    template.stub!(:will_paginate)
    assigns[:pledges] = @pledges
    template.stub!(:current_user).and_return(@user)
  end

  it 'should render' do
    do_render
  end

  def do_render
    render 'myspot/pledges/index'
  end
end
