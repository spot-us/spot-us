require File.dirname(__FILE__) + "/../../spec_helper"

describe 'users/new' do

  before do
    assigns[:title] = mock('title', :null_object => true)
    assigns[:user]  = Factory(:user)
  end

  it "should have a link to forgot password" do
    do_render
    template.should have_tag('a[href=?]', password_user_path)
  end

  it "should have a password field" do
    do_render
    template.should have_tag('input[type="password"][name=?]', "user[password]")
  end

  it "should have a password confirmation field" do
    do_render
    template.should have_tag('input[type="password"][name=?]', "user[password_confirmation]")
  end

  it "should have a first name field" do
    do_render
    template.should have_tag('input[type="text"][name=?]', "user[first_name]")
  end

  it "should have a last name field" do
    do_render
    template.should have_tag('input[type="text"][name=?]', "user[last_name]")
  end

  it "should have a dropdown menu for different user types" do
    do_render
    template.should have_tag('select[name=?]', "user[type]")
  end

  it "should have a checkbox for accepting the terms of service" do
    do_render
    template.should have_tag('input[type="checkbox"][name=?]', "user[terms_of_service]")
  end

  describe "without errors" do
    it "should not display an error message" do
      assigns[:user].valid?
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
      assigns[:user].valid?
    end

    it "should display an error message" do
      template.should_receive(:error_messages_for).with(:user)
      do_render
    end
  end

  it 'should render' do
    do_render
  end

  def do_render
    render 'users/new'
  end
end
