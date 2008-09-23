require File.dirname(__FILE__) + '/../spec_helper'

describe Pitch do
  table_has_columns(Pitch, :string, *%w(headline location requested_amount))
  table_has_columns(Pitch, :text, *%w(short_description delivery_description extended_description skills keywords))
  table_has_columns(Pitch, :boolean, *%w(deliver_text deliver_audio deliver_video deliver_photo contract_agreement))
  table_has_columns(Pitch, :datetime, *%w(expiration_date))

  describe "to support paperclip" do
    it "has a paperclip attachment for featured_image" do
      Factory(:pitch).featured_image.should be_instance_of(Paperclip::Attachment)
    end

    table_has_columns(Pitch, :string, :featured_image_file_name)
    table_has_columns(Pitch, :string, :featured_image_content_type)
    table_has_columns(Pitch, :integer, :featured_image_file_size)
    table_has_columns(Pitch, :datetime, :featured_image_updated_at)
  end
end

