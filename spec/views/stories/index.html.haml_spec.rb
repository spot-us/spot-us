require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper.rb')

describe "stories index" do
  before do
    @stories = []
    @stories.stub!(:blank?).and_return(false)
    assigns[:stories] = @stories
  end

  it "displays pagination links" do
    template.should_receive(:will_paginate)
    render "/stories/index.html.haml"
  end
end
