require File.dirname(__FILE__) + "/../../../spec_helper"

describe '/admin/pitches/index' do
  before do
    @user = Factory(:admin)
    template.stub!(:current_user).and_return(@user)
    @pitches = [Factory(:pitch, :expiration_date => Time.now + 1.day), 
                Factory(:pitch, :expiration_date => Time.now + 1.day)]
    assigns[:pitches] = @pitches
  end

  it "should render" do
    do_render
  end

  it "should include a list of blog applicants for each pitch" do
    user = Factory(:citizen)
    contributors = stub('association', :unapproved => [Factory(:contributor_application, :user => user)])
    @pitches.first.stub!(:contributor_applications).and_return(contributors)
    do_render
    response.should have_tag("select[name='user_id']") do
      with_tag("option", user.full_name)
    end
  end

  it "should link to unapproved each already-approved blogger" do
    user = Factory(:citizen)
    @pitches.first.stub!(:contributors).and_return([user])
    do_render
    response.should have_tag("a[href=?]", unapprove_blogger_admin_pitch_path(@pitches.first, :user_id => user.id), '(unapprove)')
  end

  def do_render
    render '/admin/pitches/index'
  end
end
