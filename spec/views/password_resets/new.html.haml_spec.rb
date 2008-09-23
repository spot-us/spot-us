require File.dirname(__FILE__) + "/../../spec_helper"

describe 'password_resets/new' do
  before do
    assigns[:user] = User.new
  end

  it 'should render' do
    do_render
  end

  describe "when an email has been entered" do
    before do
      params[:email] = 'somebody@example.com'
    end

    it "should fill in the email field" do
      do_render
      template.should have_tag('input[name="email"][value=?]', 'somebody@example.com')
    end

    it "should highlight the email field" do
      do_render
      template.should have_tag('.fieldWithErrors input[name="email"]')
    end
  end

  describe "when no email has been entered" do
    before do
      assigns[:email] = nil
    end

    it "should have a field to enter the email" do
      do_render
      template.should have_tag('input[name="email"]')
    end

    it "should have a submit button" do
      do_render
      template.should have_tag('input[type="image"]')
    end
  end

  def do_render
    render 'password_resets/new'
  end
end
