require File.dirname(__FILE__) + '/../spec_helper'

# dummy class on which to test, just uses users table to avoisserrors
class TestSanitizy < ActiveRecord::Base
  include Sanitizy
  set_table_name "news_items"
  cleanse_columns(:video_embed) do |sanitizer|
    sanitizer.allowed_tags.replace(%w(object param embed a))
    sanitizer.allowed_attributes.replace(%w(width height name src value allowfullscreen type href allowscriptaccess))
  end
end

describe "Sanitizy library" do
  before do
    @sanitized = TestSanitizy.new
  end

  describe "#cleanse_columns" do
    it "should set a class attribute called 'video_embed_sanitizer'" do
      TestSanitizy.should respond_to(:video_embed_sanitizer)
    end

    it "should create an instance of a sanitizer" do
      @sanitized.sanitize_declared_columns
      TestSanitizy.video_embed_sanitizer.should be_an_instance_of(HTML::WhiteListSanitizer)
    end

    it "should set the allowed attributes on the sanitizer" do
      @sanitized.sanitize_declared_columns
      TestSanitizy.video_embed_sanitizer.allowed_attributes.should_not be_empty
      TestSanitizy.video_embed_sanitizer.allowed_attributes.should be_a_kind_of(Set)
    end

    describe "sanitizing the contents of the field" do
      it "should not keep excluded tags in the field" do
        malicious_text = "<script type='text/javascript>document.write('your mom');</script>"
        @sanitized.update_attribute(:video_embed, malicious_text)
        @sanitized.video_embed.should_not == malicious_text
      end

      it "should keep allowed_tags in the field" do
        salacious_text = "<object allowfullscreen='true'><param value='salacious' /></object>"
        @sanitized.update_attribute(:video_embed, salacious_text)
        @sanitized.video_embed.should =~ /object.*?allowfullscreen.*?param\svalue.*?salacious/i
      end
    end
  end

end

