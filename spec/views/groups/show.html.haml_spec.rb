require File.dirname(__FILE__) + '/../../spec_helper.rb'

describe "group show" do

  before do
    @group = Factory(:group)
    @user1 = Factory(:citizen, :first_name => 'Lex', :last_name => 'Luthor')
    @user2 = Factory(:reporter, :first_name => 'Clark', :last_name => 'Kent')
    @pitch1 = active_pitch
    Factory(:donation, :group => @group, :pitch => @pitch1, :user => @user1, :status => 'paid', :amount => 5)
    Factory(:donation, :group => @group, :pitch => @pitch1, :user => @user2, :status => 'paid', :amount => 2)
    @pitch2 = active_pitch
    Factory(:donation, :group => @group, :pitch => @pitch2, :user => @user2, :status => 'paid', :amount => 1)
    assigns[:group] = @group
  end
  it "should list the name of the group" do
    do_render
    response.should have_tag("h2", @group.name)
  end
  it "should list the image of the group" do
    do_render
    response.should have_tag("img[src*=?]", @group.image.url(:medium))
  end
  it "should list the description of the group" do
    do_render
    response.should have_tag("p.description", @group.description)
  end
  it "should list each of the users who have donated on behalf of this group" do
    do_render
    [@user1, @user2].each {|u| response.body.should include(u.full_name)}
  end
  it "should list each of the pitches this group has donated to" do
    do_render
    [@pitch1, @pitch2].each {|p| response.body.should include(p.headline)}
  end
  it "should list the total of donations on behalf of this group" do
    do_render
    response.should have_tag("p.amount_donated")
  end
  it "shouldn't show the pitch header if there are no donations" do
    @group.stub!(:pitches).and_return([])
    do_render
    response.should_not have_tag("h2", "Pitches This Group Supports")
  end

  def do_render
    render '/groups/show.html.haml'
  end

end
