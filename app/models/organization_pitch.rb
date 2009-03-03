class OrganizationPitch < ActiveRecord::Base
  belongs_to :organization
  belongs_to :pitch

  validates_presence_of :organization, :pitch
  validates_uniqueness_of :pitch_id, :scope => :organization_id
end
