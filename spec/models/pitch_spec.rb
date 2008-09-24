require File.dirname(__FILE__) + '/../spec_helper'

describe Pitch do
  table_has_columns(Pitch, :string,   "requested_amount")
  table_has_columns(Pitch, :text,     "short_description")
  table_has_columns(Pitch, :text,     "delivery_description")
  table_has_columns(Pitch, :text,     "extended_description")
  table_has_columns(Pitch, :text,     "skills")
  table_has_columns(Pitch, :boolean,  "deliver_text")
  table_has_columns(Pitch, :boolean,  "deliver_audio")
  table_has_columns(Pitch, :boolean,  "deliver_video")
  table_has_columns(Pitch, :boolean,  "deliver_photo")
  table_has_columns(Pitch, :boolean,  "contract_agreement")
  table_has_columns(Pitch, :datetime, "expiration_date")

  requires_presence_of Pitch, :requested_amount
  requires_presence_of Pitch, :short_description
  requires_presence_of Pitch, :extended_description
  requires_presence_of Pitch, :delivery_description
  requires_presence_of Pitch, :skills
  requires_presence_of Pitch, :keywords
  requires_presence_of Pitch, :featured_image_caption

  it "requires a featured image to be set" do
    pitch = Factory.build(:pitch, :featured_image => nil)
    pitch.should_not be_valid
    pitch.should have(1).error_on(:featured_image_file_name)
  end

  it { Factory(:pitch).should have_many(:donations) }
  it { Factory(:pitch).should belong_to(:user) }

  it "requires contract_agreement to be true" do
    Factory.build(:pitch, :contract_agreement => false).should_not be_valid
  end

  it "requires location to be a valid LOCATION" do
    Factory.build(:pitch, :location => LOCATIONS.first).should be_valid
    Factory.build(:pitch, :location => "invalid").should_not be_valid
  end

  describe "to support STI" do
    it "descends from NewItem" do
      Pitch.ancestors.include?(NewsItem)
    end
  end

  describe "a pitch with donations" do
    before(:each) do
      @pitch = Factory(:pitch)
      @donation = Factory(:donation, :pitch => @pitch)
      @pitch.reload
    end

    it "has donations" do
      @pitch.should be_donated_to
    end
  end
end

