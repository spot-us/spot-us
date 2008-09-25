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

  it { Factory(:pitch).should have_many(:affiliations) }
  it { Factory(:pitch).should have_many(:tips) }
  it { Factory(:pitch).should have_many(:donations) }
  it { Factory(:pitch).should have_many(:supporters)}
  
  describe "creating" do
    it "is creatable by reporter" do
      Pitch.createable_by?(Factory(:reporter)).should be
    end

    it "is not creatable by user" do
      Pitch.createable_by?(Factory(:user)).should_not be_true
    end

    it "is not creatable if not logged in" do
      Pitch.createable_by?(nil).should_not be
    end
  end

  it "returns true on #pitch?" do
    Factory(:pitch).should be_a_pitch
  end
  
  it "returns false on #tip?" do
    Factory(:pitch).should_not be_a_tip
  end

  it "requires a featured image to be set" do
    pitch = Factory.build(:pitch, :featured_image => nil)
    pitch.should_not be_valid
    pitch.should have(1).error_on(:featured_image_file_name)
  end

  it "requires contract_agreement to be true" do
    Factory.build(:pitch, :contract_agreement => false).should_not be_valid
  end

  it "requires location to be a valid LOCATION" do
    user = Factory(:user)
    Factory.build(:pitch, :location => LOCATIONS.first, :user => user).should be_valid
    Factory.build(:pitch, :location => "invalid", :user => user).should_not be_valid
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
    
    it "returns all donated money on total_amount_donated" do
      Factory(:donation, :pitch=> @pitch, :amount => 3000)
      Factory(:donation, :pitch=> @pitch, :amount => 2)
      Factory(:donation, :pitch=> @pitch, :amount => 1)

      @pitch.reload
      @pitch.total_amount_donated.to_f.should == @pitch.donations.map(&:amount).map(&:to_f).sum
    end
  end
  
  describe "newest pitches" do
    before do
      @items = [Factory(:pitch), Factory(:pitch), Factory(:pitch)]
      @items.reverse.each_with_index do |item, i|
        NewsItem.update_all("created_at = '#{i.days.ago.to_s(:db)}'", "id=#{item.id}")
      end
      Factory(:tip)
      @items.each(&:reload)
      unless @items.collect(&:created_at).uniq.size == 3
        violated "need 3 different created_at values to test sorting"
      end

      @result = Pitch.newest
    end

    it "should return items in reverse created at order" do
      @result.should == @result.sort {|b, a| a.created_at <=> b.created_at }
    end

    it "should return all items" do
      @result.size.should == @items.size
    end

    it "should only return pitches" do
      @result.detect {|item| !item.pitch? }.should be_nil
    end
  end

  it "should use the newest pitch as the featured pitch" do
    newest = mock('newest')
    Pitch.should_receive(:newest).with().and_return(newest)
    newest.should_receive(:first).and_return('first')
    Pitch.featured.should == 'first'
  end
end

