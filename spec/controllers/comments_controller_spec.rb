require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe CommentsController do
  describe "POST to create" do
    before do
      post :create, :comment => {:foo => 'bar'}, :pitch_id => 1
    end
    it_denies_access
  end
end
