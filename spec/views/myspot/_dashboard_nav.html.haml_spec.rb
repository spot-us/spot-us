require File.dirname(__FILE__) + "/../../spec_helper"

describe 'myspot/_dashboard_nav.html.haml' do
  before do
    @user = Factory(:reporter)

    template.stub!(:current_user).and_return(@user)
  end

  it "should look for the current user" do
    template.should_receive(:current_user).at_least(1).with().and_return(@user)
    do_render
  end

  %w(pledges tips posts).each do |collection|
    it "should look for the current user's #{collection} count" do
      items = mock(collection)
      @user.should_receive(collection).and_return(items)
      items.should_receive(:count).and_return(1)
      do_render
    end
  end
  
  it "should look for the current user's paid donation count" do
    items = mock(:donations)
    @user.should_receive(:donations).with().and_return(items)
    items.should_receive(:paid).with().and_return(items)
    items.should_receive(:count).with().and_return(1)
    do_render
  end

  it "should check the pitches count for a reporter" do
    @user = Factory(:reporter)
    template.stub!(:current_user).and_return(@user)
    pitches = mock('pitches')
    @user.should_receive(:pitches).with().and_return(pitches)
    pitches.should_receive(:count).with().and_return(1)
    do_render
  end

  it "should not check the pitches count for a citizen" do
    @user = User.find(Factory(:user).to_param)
    template.stub!(:current_user).and_return(@user)
    violated "the user must be a citizen" unless @user.citizen?
    @user.should_not_receive(:pitches)
    do_render
  end

  it 'should render' do
    do_render
  end

  def do_render
    render 'myspot/_dashboard_nav.html.haml'
  end
end
