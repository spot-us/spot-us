require File.dirname(__FILE__) + '/../spec_helper'

# dummy class on which to test, just uses users table to avoisserrors
class SingularSanitizy < ActiveRecord::Base
  include Sanitizy
  set_table_name "news_items"
  cleanse_columns(:video_embed) do |sanitizer|
    sanitizer.allowed_tags = %w(object param embed a img)
    sanitizer.allowed_attributes = %w(width height name src value allowFullScreen type href allowScriptAccess style wmode pluginspage classid codebase data quality)
  end
end

describe "Sanitizy library" do
  before do
    @sanitized = SingularSanitizy.new
  end

  describe "#cleanse_columns" do
    it "should set a class attribute called 'video_embed_sanitizer'" do
      @sanitized.should respond_to(:video_embed_sanitizer)
    end

    it "should create an instance of a sanitizer" do
      @sanitized.sanitize_declared_columns
      @sanitized.video_embed_sanitizer.should be_an_instance_of(Sanitizy::Sanitizer)
    end

    it "should set the allowed attributes on the sanitizer" do
      @sanitized.sanitize_declared_columns
      @sanitized.video_embed_sanitizer.allowed_attributes.should_not be_empty
      @sanitized.video_embed_sanitizer.allowed_attributes.should be_a_kind_of(Set)
    end

    describe "sanitizing the contents of the field" do
      it "should not keep excluded tags in the field" do
        malicious_text = "<script type='text/javascript>document.write('your mom');</script>"
        @sanitized.update_attribute(:video_embed, malicious_text)
        @sanitized.video_embed.should_not == malicious_text
      end

      it "should keep allowed_tags in the field" do
        salacious_text =<<-EOS
        <object type="application/x-shockwave-flash"
          classid="clsid:d27cdb6e-ae6d-11cf-96b8-444553540000"
          codebase="http://fpdownload.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=9,0,0,0"
          width="300" height="271" id="spo_tADnqEL3EfIPb8xR"
          data="http://farm.sproutbuilder.com/load/tADnqEL3EfIPb8xR.swf">
          <param name="wmode" value="transparent" />
          <param name="align" value="middle" />
          <param name="allowFullScreen" value="true" />
          <param name="allowScriptAccess" value="always" />
          <param name="quality" value="best" />
          <param name="movie" 
            value="http://farm.sproutbuilder.com/load/tADnqEL3EfIPb8xR.swf" />
          <embed type="application/x-shockwave-flash" 
            pluginspage="http://www.macromedia.com/go/getflashplayer" 
            name="spe_tADnqEL3EfIPb8xR" 
            src="http://farm.sproutbuilder.com/load/tADnqEL3EfIPb8xR.swf" 
            width="300"
            height="271"
            wmode="transparent"
            align="middle"
            allowFullScreen="true"
            allowScriptAccess="always"
            quality="best">
          </embed>
          </object>
          <img style="visibility:hidden;width:0px;height:0px;" 
            border=0 width=0 height=0 
            src="http://counters.gigya.com/wildfire/IMP/CXNID=2000002.0NXC/bT*xJmx*PTEyMzIxMjA*MjAwNDImcHQ9MTIzMjEyMTE1OTc1OCZwPTEyMDc*MSZkPXRBRG5xRUwzRWZJUGI4eFImZz*xJnQ9Jm89YWI3MzM*ODI1YjQ*NDI3NTg5M2E2YjcyN2Y*YTJjYTU=.gif" />
        EOS
        @sanitized.update_attribute(:video_embed, salacious_text)
        @sanitized.video_embed.should =~ /object.*?classid.*?param\sname.*img/mi
      end
    end
  end

end

class MultipleSanitizy < ActiveRecord::Base
  include Sanitizy
  set_table_name 'news_items'
  cleanse_column(:short_description) do |s|
    s.allowed_tags = %w(baz quuz)
  end
  cleanse_column(:video_embed) do |s|
    s.allowed_tags = %w(foo bar)
  end
end

describe "Multiple sanitizers on a model" do
  before do
    @sanitized = MultipleSanitizy.new
  end

  it "should have two columns stored in self.class.sanitizy_columns" do
    MultipleSanitizy.sanitizy_columns.size.should == 2
  end

  describe "short description" do
    it "should only allow baz and quuz tags" do
      @sanitized.short_description_sanitizer.allowed_tags.should == ['baz', 'quuz'].to_set
    end
  end
  describe "video embed" do
    it "should only allow foo and bar tags" do
      @sanitized.video_embed_sanitizer.allowed_tags.should == ['foo', 'bar'].to_set
    end

    it "should be a new instance of a sanitizer" do
      @sanitized.video_embed_sanitizer.should_not == @sanitized.short_description_sanitizer
    end
  end
end

class SetSanitizy < ActiveRecord::Base
  include Sanitizy
  set_table_name 'news_items'
  cleanse_column(:short_description) do |s|
    s.allowed_tags.delete('div')
  end
  cleanse_column(:video_embed) do |s|
    s.allowed_tags.replace(['object'])
  end
end

describe "when using Set operations" do
  before do
    @sanitized = SetSanitizy.new
  end

  it "should allow deleting tags" do
    @sanitized.short_description_sanitizer.allowed_tags.should_not include('div')
  end

  it "should allow replacing tags" do
    @sanitized.video_embed_sanitizer.allowed_tags.should == ['object'].to_set
  end
end

