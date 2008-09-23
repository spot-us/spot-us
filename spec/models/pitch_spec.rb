require File.dirname(__FILE__) + '/../spec_helper'

describe Pitch do
  table_has_columns(Pitch, :string, *%w(headline location requested_amount))
  table_has_columns(Pitch, :text, *%w(short_description delivery_description extended_description skills keywords))
  table_has_columns(Pitch, :boolean, *%w(deliver_text deliver_audio deliver_video deliver_photo contract_agreement))
  table_has_columns(Pitch, :datetime, *%w(expiration_date))
end

