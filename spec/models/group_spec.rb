require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Group do
  requires_presence_of Group, :name
  requires_presence_of Group, :description

  it { Group.should have_many(:donations) }

  it "should have an image attachment" do
    Factory(:group).image.should be_instance_of(Paperclip::Attachment)
  end

end
