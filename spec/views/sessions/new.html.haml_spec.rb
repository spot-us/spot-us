require File.dirname(__FILE__) + "/../../spec_helper"

describe 'sessions/new' do

  before do
    assigns[:title] = mock('title', :null_object => true)
    assigns[:user]  = Factory(:user)
  end

  it "should have a link to reset the user's password" do
    do_render
    template.should have_tag('a[href=?]', new_password_reset_path)
  end

  describe "without errors" do
    before do
      assigns[:user].should be_valid
    end

    it "should not display an error message" do
      template.should_receive(:content_for).never
      do_render
    end
  end

  describe "with a new user" do
    before do
      assigns[:user] = User.new
    end

    it "should not display an error message" do
      template.should_receive(:content_for).never
      do_render
    end
  end

  describe "with errors" do
    before do
      assigns[:user].email = nil
      assigns[:user].should_not be_valid
    end

    it "should display an error message" do
      template.should_receive(:content_for).once.with(:error)
      do_render
    end
  end

  it 'should render' do
    do_render
  end

  def do_render
    render 'sessions/new'
  end
end
