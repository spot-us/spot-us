require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/pitches/show.html.haml" do
  include ActionView::Helpers::AssetTagHelper

  before(:each) do
    @pitch = active_pitch
    assigns[:pitch] = @pitch
    @citizen = Factory(:citizen)
    template.stub!(:current_user).and_return(@citizen)
  end

  it "should render" do
    do_render
  end

  it "should render a link to the story if it has been published" do
    story = Factory(:story)
    story.stub!(:published?).and_return(true)
    @pitch.fact_checker = Factory(:citizen)
    @pitch.story = story
    do_render
    response.should have_tag("a[href=?]", story_path(story))
  end

  it "should not render a link to the story if it has not been published" do
    story = Factory(:story)
    story.stub!(:published?).and_return(false)
    @pitch.fact_checker = Factory(:citizen)
    @pitch.story = story
    do_render
    response.should_not have_tag("a[href=?]", story_path(story))
  end

  it "should render the headline" do
    do_render
    template.should have_tag('h2.headline', /#{@pitch.headline}/i)
  end

  describe "blog posts" do
    before do
      @pitch.stub!(:posts).and_return([Factory(:post, :body => "<div><p>Some blog post text</p></div>", :pitch => @pitch)])
    end
    it "should include blog posts" do
      do_render
      template.should have_tag("h3", "Blog Posts")
    end

    it "should strip html out of blog posts" do
      do_render
      template.should have_tag("div.body", "Some blog post text")
    end
  end

  describe "approving and unapproving as an admin" do
    before do
      @admin = Factory(:admin)
      @admin.stub!(:admin?).and_return(true)
      template.stub!(:logged_in?).and_return(true)
      template.stub!(:current_user).and_return(@admin)
    end
    it "should have an approve button if it's currently unapproved" do
      @pitch = Factory(:pitch)
      @pitch.stub!(:approvable_by?).and_return(true)
      @pitch.stub!(:unapproved?).and_return(true)
      assigns[:pitch] = @pitch
      do_render
      template.should have_tag('a[href$=?]', approve_admin_pitch_path(@pitch))
    end
    it "should have an unapprove button if it's currently active" do
      @pitch = active_pitch
      @pitch.stub!(:approvable_by?).and_return(true)
      @pitch.stub!(:active?).and_return(true)
      assigns[:pitch] = @pitch
      do_render
      template.should have_tag('a[href$=?]', unapprove_admin_pitch_path(@pitch))
    end
  end

  it 'should not have approval buttons if the current user is not an admin' do
    template.stub!(:logged_in?).and_return(true)
    template.stub!(:current_user).and_return(@pitch.user)
    do_render
    template.should_not have_tag('a[href$=?]', approve_admin_pitch_path(@pitch))
  end

  it "should have an edit button if the current user is the creator of the pitch" do
    template.stub!(:logged_in?).and_return(true)
    template.stub!(:current_user).and_return(@pitch.user)
    do_render
    template.should have_tag('a[href$=?]', edit_pitch_path(@pitch))
  end

  it "should not have an edit button if the current user isn't the creator of the pitch" do
    template.stub!(:logged_in?).and_return(true)
    template.stub!(:current_user).and_return(Factory(:user))
    do_render
    template.should_not have_tag('a[href$=?]', edit_pitch_path(@pitch))
  end

  it "should not have an edit button if not logged in" do
    template.stub!(:logged_in?).and_return(false)
    template.stub!(:current_user).and_return(nil)
    do_render
    template.should_not have_tag('a[href$=?]', edit_pitch_path(@pitch))
  end

  it "should have a make a blog post button if the user is allowed to" do
    @pitch.stub!(:postable_by?).and_return(true)
    do_render
    template.should have_tag('a[href=?]', new_pitch_post_path(@pitch))
  end

  it "should not have a make a blog post button if the user isn't allowed to" do
    @pitch.stub!(:postable_by?).and_return(false)
    do_render
    template.should_not have_tag('a[href=?]', new_pitch_post_path(@pitch))
  end

  it "has an accept donations button if the current user is the reporter and the pitch is not fully funded" do
    @pitch.stub!(:fully_funded?).and_return(false)
    template.stub!(:current_user).and_return(@pitch.user)
    do_render
    response.should have_tag("a[href=?]", accept_myspot_pitch_path(@pitch))
  end

  it "does not have an accept donations button otherwise" do
    @pitch.stub!(:fully_funded?).and_return(true)
    @pitch.stub!(:story).and_return(Factory(:story))
    template.stub!(:current_user).and_return(@pitch.user)
    do_render
    response.should_not have_tag("a[href=?]", accept_myspot_pitch_path(@pitch))
  end

  it "has a 'go to story' button if current user is peer reviewer and pitch has story" do
    @reporter = Factory(:reporter)
    @pitch.stub!(:story).and_return(stub_model(Story))
    @pitch.stub!(:fact_checker).and_return(@reporter)
    template.stub!(:logged_in?).and_return(true)
    template.stub!(:current_user).and_return(@reporter)
    do_render
    template.should have_tag('a[href=?]', story_path(@pitch.story))
  end

  it "should not have a 'go to story' button otherwise" do
    @pitch.stub!(:story).and_return(Factory(:story))
    @pitch.stub!(:fact_checker).and_return(Factory(:reporter))
    template.stub!(:logged_in?).and_return(true)
    template.stub!(:current_user).and_return(@reporter)
    do_render
    template.should_not have_tag('a[href=?]', story_path(@pitch.story))
  end

  it "should have a create a story button if the pitch is funded and the current user is the reporter" do
    @pitch.stub!(:fully_funded?).and_return(true)
    @pitch.stub!(:story).and_return(Factory(:story))
    template.stub!(:current_user).and_return(@pitch.user)
    do_render
    response.should have_tag("a[href=?]", edit_story_path(@pitch.story))
  end

  it "should not have a create a story button otherwise" do
    @pitch.stub!(:fully_funded?).and_return(false)
    @pitch.stub!(:story).and_return(Factory(:story))
    do_render
    response.should_not have_tag("a[href=?]", edit_story_path(@pitch.story))
  end

  it "should render short description" do
    do_render
    template.should have_tag('p', /#{@pitch.short_description}/i)
  end

  it "should display photo if there is one" do
    assigns[:pitch].stub!(:featured_image?).and_return(true)
    assigns[:pitch].stub!(:featured_image).and_return(mock("image", :url => "photo"))
    do_render
    template.should have_tag('img[src = ?]', "/images/photo")
  end

  it "should not display a photo if there isn't one" do
    assigns[:pitch].stub!(:featured_image?).and_return(false)
    do_render
    template.should_not have_tag('img[src = ?]', "/images/photo")
  end

  it "displays license if there is one" do
    assigns[:pitch].stub!(:license).and_return('<a href="http://creativecommons.org/licenses/by-nd/3.0/legalcode"><img src="http://i.creativecommons.org/l/by-nc-sa/3.0/us/88x31.png"/></a>')
    do_render
    response.should have_tag("a[href*=?]", 'http://creativecommons.org')
  end

  it "doesn't display the license header if it doesn't have a license" do
    assigns[:pitch].stub!(:license).and_return(nil)
    do_render
    response.should_not have_tag("h3", "License")
  end

  it "not blow up with related pitches" do
    @pitch.tips = [Factory(:tip), Factory(:tip)]
    do_render
  end

  it "shows organizational supporters when they exist" do
    organization = Factory(:organization)
    @pitch.stub!(:supporting_organizations).and_return([organization])
    do_render
    template.should have_tag('div.organizational_support')
  end

  describe "with a logged in user that hasn't donated" do
    before do
      @user = Factory(:user)
      unless @user.donations.empty?
        violated "user should not have any donations"
      end
      template.stub!(:logged_in?).and_return(true)
      template.stub!(:current_user).and_return(@user)
    end

    it "should display a form to add a donation" do
      do_render
      template.should have_tag('form[action=?][method="post"]', myspot_donations_path)
    end
  end

  describe "with a logged in user that has donated the personal maximum" do
    before do
      @user = Factory(:user)
      @user.stub!(:can_donate_to?).and_return(false)
      template.stub!(:logged_in?).and_return(true)
      template.stub!(:current_user).and_return(@user)
    end

    it "should have a link to edit donations" do
      do_render
      template.should have_tag('a[href=?]', edit_myspot_donations_amounts_path)
    end

    it "should not display a form to add a donation" do
      do_render
      template.should_not have_tag('form[action=?][method="post"]', myspot_donations_path)
    end
  end

  describe "with a logged in user that has not donated the personal maximum" do
    before do
      @user = Factory(:user)
      @user.stub!(:can_donate_to?).and_return(true)
      template.stub!(:logged_in?).and_return(true)
      template.stub!(:current_user).and_return(@user)
    end

    it "should not have a link to edit donations" do
      do_render
      template.should_not have_tag('a[href=?]', edit_myspot_donations_amounts_path)
    end

    it "should display a form to add a donation" do
      do_render
      template.should have_tag('form[action=?][method="post"]', myspot_donations_path)
    end
  end

  describe "half fund widget" do
    before do
      template.stub!(:current_user).and_return(Factory(:organization))
    end
    it "should appear for organizations" do
      do_render
      response.should have_tag("div.half_fund")
    end
    it "should not appear for citizens" do
      template.stub!(:current_user).and_return(Factory(:citizen))
      do_render
      response.should_not have_tag("div.half_fund")
    end
    it "should not appear for reporters" do
      template.stub!(:current_user).and_return(Factory(:reporter))
      do_render
      response.should_not have_tag("div.half_fund")
    end
    it "should appear for pitches that are 50% or less funded" do
      @pitch.stub!(:half_funded?).and_return(true)
      do_render
      response.should_not have_tag("div.half_fund")
    end
    it "should not appear for pitches that are more than 50% funded" do
      template.stub!(:current_user).and_return(Factory(:organization))
      @pitch.stub!(:half_funded?).and_return(false)
      do_render
      response.should have_tag("div.half_fund")
    end
  end

  describe "fact checking widget" do

    describe "when no fact checker has been assigned" do
      before do
        @pitch = Factory(:pitch)
        @applicant = Factory(:citizen)
        template.stub!(:current_user).and_return(@applicant)
        assigns[:pitch] = @pitch
      end
      it "should show Join Reporting Team button always" do
        template.stub!(:current_user).and_return(nil)
        do_render
        response.should have_tag("div.apply_to_contribute")
      end
      it "Join Reporting Team button should link to correct action" do
        do_render
        response.should have_tag("a[href=?]", apply_to_contribute_pitch_path(@pitch))
      end
      it "Join Reporting Team button should link to login in a facebox if necessary" do
        template.stub!(:current_user).and_return(nil)
        do_render
        response.should have_tag("a[href*=?][class='authbox']", new_session_path)
      end
      it "should not show when the current user is the reporter for the pitch" do
        template.stub!(:current_user).and_return(@pitch.user)
        do_render
        response.should_not have_tag("a[href=?]", apply_to_contribute_pitch_path(@pitch))
      end
      it "should show an Applied! image if the current user has applied" do
        @pitch.stub!(:contributor_applicants).and_return([@applicant])
        do_render
        response.should have_tag("img.applied_to_fact_check")
      end
    end
  end

  describe "fully fund widget" do
    it "should appear for organizations" do
      template.stub!(:current_user).and_return(Factory(:organization))
      do_render
      response.should have_tag("div.fully_fund")
    end
    it "should not appear for citizens" do
      template.stub!(:current_user).and_return(Factory(:citizen))
      do_render
      response.should_not have_tag("div.fully_fund")
    end
    it "should not appear for reporters" do
      template.stub!(:current_user).and_return(Factory(:reporter))
      do_render
      response.should_not have_tag("div.fully_fund")
    end
    it "should not appear for fully funded pitches" do
      template.stub!(:current_user).and_return(Factory(:organization))
      @pitch.stub!(:fully_funded?).and_return(true)
      do_render
      response.should_not have_tag("div.fully_fund")
    end
    it "should appear if the pitch is not fully funded" do
      template.stub!(:current_user).and_return(Factory(:organization))
      @pitch.stub!(:fully_funded?).and_return(false)
      do_render
      response.should have_tag("div.fully_fund")
    end
  end

  describe "group support widget" do
    before do
      @group1 = Factory(:group)
      Factory(:donation, :group => @group1, :pitch => @pitch, :amount => 1, :status => 'paid')
      Factory(:donation, :group => @group1, :pitch => @pitch, :amount => 2, :status => 'paid')
      @group2 = Factory(:group)
      Factory(:donation, :group => @group2, :pitch => @pitch, :amount => 4, :status => 'paid')
    end
    it 'only displays if there are supporting groups' do
      @pitch.stub!(:donating_groups).and_return([])
      do_render
      response.should_not have_tag("div.group_supporters")
    end
    it "should list each donating group" do
      do_render
      [@group1, @group2].each {|g| response.body.should include(g.name) }
    end
    it "should list the sum of donations for each group" do
      do_render
      response.body.should include("$3")
      response.body.should include("$4")
    end
    it "should list the image for each group" do
      do_render
      [@group1, @group2].each {|g| response.should have_tag("img[src*=?]", g.image.url)}
    end
    it "should link to each group" do
      do_render
      [@group1, @group2].each {|g| response.should have_tag("a[href=?]", group_path(g))}
    end
    it "includes a link to all groups" do
      do_render
      response.should have_tag("a[href=?]", groups_path)
    end
  end

  describe "show support widget" do
    before do

    end
    it "should appear for organizations" do
      template.stub!(:current_user).and_return(Factory(:organization))
      do_render
      response.should have_tag("div.show_support")
    end
    it "should not appear for citizens" do
      template.stub!(:current_user).and_return(Factory(:citizen))
      do_render
      response.should_not have_tag("div.show_support")
    end
    it "should not appear for reporters" do
      template.stub!(:current_user).and_return(Factory(:reporter))
      do_render
      response.should_not have_tag("div.show_support")
    end
    it "should not appear if the organization has already supported the pitch" do
      organization = Factory(:organization)
      organization.stub!(:shown_support_for?).and_return(true)
      template.stub!(:current_user).and_return(organization)
      do_render
      response.should_not have_tag("div.show_support")
    end
  end

  def do_render
    render '/pitches/show.html.haml'
  end

end



