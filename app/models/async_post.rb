class AsyncPost < ActiveRecord::Base
  belongs_to :user
  named_scope :facebook_wall_updates_to_post, :conditions=>"status=0 and post_type='Facebook'", :order => 'created_at desc'
end