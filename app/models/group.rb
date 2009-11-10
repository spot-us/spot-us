class Group < ActiveRecord::Base
  has_many :donations
  validates_presence_of :name, :description

  has_attached_file :image,
                    :styles => { :thumb => '50x50#', :medium => "200x150#" },
                    :storage => :s3,
                    :s3_credentials => "#{RAILS_ROOT}/config/s3.yml",
                    :bucket =>   S3_BUCKET,
                    :path => "news_items/" <<
                    :default_url => "/images/default_avatar.png",
                    :path        => "groups/:attachment/:id_partition/:basename_:style.:extension",
                    :url         => "groups/:attachment/:id_partition/:basename_:style.:extension"

  def donations_for_pitch(pitch)
    donations.for_pitch(pitch).map(&:amount).sum
  end

  def donors
    donations.map(&:user).uniq
  end

  def total_donations
    donations.map(&:amount).sum
  end

  def amount_donated_by(user)
    donations.by_user(user).map(&:amount).sum
  end

  def pitches
    donations.map(&:pitch).uniq
  end

end
