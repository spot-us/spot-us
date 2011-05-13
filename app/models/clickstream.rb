class Clickstream < ActiveRecord::Base

  belongs_to :clickstreamable, :polymorphic => true
  belongs_to :user

  named_scope :last_unprocessed, :conditions=>"clickstreamable_id is not null and clickstreamable_type is not null and status=0", :order => "created_at asc"
  named_scope :unprocessed, :conditions=>"clickstreamable_id is not null and clickstreamable_type is not null and status=0", :group => "clickstreamable_id, clickstreamable_type", :select => "clickstreamable_id, clickstreamable_type, count(*) as cnt"

end
