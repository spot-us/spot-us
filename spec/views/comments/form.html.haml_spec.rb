require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/comments/_form.html.haml" do

  before(:each) do
    pitch = active_pitch
    assigns[:pitch] = pitch
  end

  template = <<EOT
- form_for [@pitch, Comment.new(:commentable => @pitch)], :html => { :id => 'comments_form', :class => "auth" } do |f|
  = render :partial => '/comments/form', :locals => {:f => f}
EOT

  it "to combat bots has a text field named comment_blog_url with a class of highlight_required" do
    render :inline => template, :type => :haml
    response.should have_tag('input.highlight_required[type=text]')
  end
end


