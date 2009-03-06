class Group < ActiveRecord::Base
  has_many :donations
  validates_presence_of :name, :description

  has_attached_file :image,
                    :styles      => { :thumb => '50x50#' },
                    :default_url => "/images/default_avatar.png",
                    :path        => ":rails_root/public/system/groups/:attachment/:id_partition/:basename_:style.:extension",
                    :url         => "/system/groups/:attachment/:id_partition/:basename_:style.:extension"
end
