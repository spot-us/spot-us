require File.dirname(__FILE__) + '/../../spec_helper.rb'

describe "showing a blog post" do
  def do_render
    render '/posts/show.html.haml'
  end
  describe 'for all users' do
    before do
      @pitch = Factory(:pitch)
      @post = Factory(:post, :pitch => @pitch)
      assigns[:post] = @post
      do_render
    end
    it "should link to the pitch" do
      response.should have_tag("a[href=?]", pitch_url(@pitch))
    end
    it "should list the title" do
      response.body.should include(@post.title)
    end
    it "should show the body" do
      response.body.should include(@post.body)
    end
    it "should show the media embed" do
      response.body.should include(@post.media_embed)
    end
    it "should show the user" do
      response.body.should include(@post.user.full_name)
    end
    it "should include donations button" do
      response.should have_tag("div#inline_donation_form_#{@pitch.id}")
    end
    it "should include the post" do
      response.should have_tag("h4", @post.title)
    end
    it "should include supporters" do
      response.should have_tag("h2", "Supporters")
    end
    it "should have an RSS link" do
      response.should have_tag("a[href=?]", blog_posts_pitch_path(@pitch, :format => :rss))
    end
  end

  describe 'special cases' do
    before do
      @pitch = Factory(:pitch)
      @post = Factory(:post, :pitch => @pitch)
      assigns[:post] = @post
    end
    it "should have an edit link if the current user can edit this post" do
      @pitch.stub!(:postable_by?).and_return(true)
      do_render
      response.should have_tag("a[href=?]", edit_pitch_post_path(@pitch, @post))
    end
    it "should not have an edit link otherwise" do
      @pitch.stub!(:postable_by?).and_return(false)
      do_render
      response.should_not have_tag("a[href=?]", edit_pitch_post_path(@pitch, @post))
    end
  end
end
