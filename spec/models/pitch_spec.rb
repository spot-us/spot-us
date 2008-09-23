require File.dirname(__FILE__) + '/../spec_helper'

describe Pitch do
  table_has_columns(Pitch, :string, *%w(headline location requested_amount))

  %w(short_description delivery_description extened_desciption skills keywords)

  %w(text_delivery audio_delivery video_delivery photo_delivery contract_agreement)

  %w(expiration_date)
end

