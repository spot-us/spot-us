class Api::PitchesController < ApplicationController
  
  def show
    # get the pitch
    pitch = Pitch.find_by_id(params[:id])
    
    # main pitch details
    arr = ActiveSupport::OrderedHash.new
    arr[:id] = pitch.id
    arr[:slug] = pitch.slug
    arr[:headline] = pitch.headline
    arr[:permalink] = pitch.permalink
    arr[:status] = pitch.status
    arr[:created_at] = pitch.created_at
    arr[:updated_at] = pitch.updated_at
    arr[:expiration_date] = pitch.expiration_date
    arr[:is_funded] = pitch.fully_funded?
    arr[:thumb_url] = pitch.featured_image(:small_hero) 
    arr[:description] = pitch.short_description.strip_and_shorten_character_limit(80)
    arr[:currency] = "credits"
    
    # author
    author = ActiveSupport::OrderedHash.new
    author[:full_name] = pitch.user.full_name
    author[:profile_url] = pitch.user.permalink
    author[:thumb_url] = pitch.user.photo.url(:thumb)
    arr[:author] = author
    
    # progress
    progress = ActiveSupport::OrderedHash.new
    progress[:raised_amount] = pitch.funding_needed>0 ? pitch.current_funding : pitch.total_amount_donated
    progress[:funding_in_percentage] = pitch.funding_needed>0 ? pitch.funding_in_percentage : 100
    progress[:funding_needed] = pitch.funding_needed>0 ? pitch.funding_needed : 0
    progress[:requested_amount] = pitch.funding_needed>0 ? pitch.requested_amount : pitch.total_amount_donated
    arr[:progress] = progress
    
    # donors
    donors = ActiveSupport::OrderedHash.new
    
    # individuals
    if pitch.supporters.any?
      
      p = ActiveSupport::OrderedHash.new
      p[:amount_raised] = pitch.total_amount_donated
      p[:nr_of_supporters] = pitch.supporters.length
      
      supporter_arr = []
    	pitch.supporters.each do |supporter|
    	  s = ActiveSupport::OrderedHash.new
    	  s[:full_name] = supporter.full_name
    	  s[:profile_url] = supporter.permalink
    	  s[:thumb_url] = supporter.photo.url(:thumb)
    	  supporter_arr << s
    	end
    	p[:supporters] = supporter_arr
    	donors[:supporters] = p
    end
    
    # donating groups
    if pitch.donating_groups.any?
      p = ActiveSupport::OrderedHash.new
      p[:amount_raised] = pitch.total_amount_donated
      p[:nr_of_supporters] = pitch.donating_groups.length
      
      supporter_arr = []
      pitch.donating_groups.each do |supporter|
        s = ActiveSupport::OrderedHash.new
      	s[:full_name] = supporter.full_name
      	s[:profile_url] = supporter.permalink
      	s[:thumb_url] = supporter.image.url(:thumb) if supporter.respond_to? :image
      	s[:thumb_url] = supporter.photo.url(:thumb) if supporter.respond_to? :photo
      	supporter_arr << s
      end
      p[:supporters] = supporter_arr
      donors[:groups] = p
    end
    
    # donating organizations 
    if pitch.supporting_organizations.any? || pitch.donations_and_credits.from_organizations.any?	
    	supporters = []
    	supporters.concat(pitch.supporting_organizations) if pitch.supporting_organizations.any?
    	supporters.concat(pitch.donations_and_credits.from_organizations.map(&:user)) if pitch.donations_and_credits.from_organizations.any?
    	supporters.uniq!
      
      p = ActiveSupport::OrderedHash.new
      p[:amount_raised] = pitch.donations_and_credits.from_organizations.map{ |d| d.amount }.sum
      p[:nr_of_supporters] = supporters.length
      
      supporter_arr = []
      supporters.each  do |supporter|
        s = ActiveSupport::OrderedHash.new
    	  s[:full_name] = supporter.full_name
    	  s[:profile_url] = supporter.permalink
    	  s[:thumb_url] = supporter.image.url(:thumb) if supporter.respond_to? :image
      	s[:thumb_url] = supporter.photo.url(:thumb) if supporter.respond_to? :photo
    	  supporter_arr << s
    	end
    	p[:supporters] = supporter_arr
    	donors[:organizations] = p
    end
    
    # cca support
    unless Donation.cca_supporters(pitch.id).all.empty?
    	donations = Donation.cca_supporters(pitch)
      
      p = ActiveSupport::OrderedHash.new
      p[:amount_raised] = Donation.cca_supporters(pitch.id).map{ |obj| obj.cca_total_amount.to_f }.sum
      p[:nr_of_supporters] = donations.length
      
      supporter_arr = []
    	donations.each do |donation|
        cca = donation.cca
    		if cca && cca.user
    		  s = ActiveSupport::OrderedHash.new
      	  s[:full_name] = cca.user.full_name
      	  s[:cca_url] = cca_path(cca, {:only_path => false})
      	  s[:thumb_url] = cca.user.photo.url(:thumb)
      	  supporter_arr << s
    		end
    	end
    	p[:supporters] = supporter_arr
    	donors[:cca] = p
    end
    
    arr[:donors] = donors
    
    render :json => arr
  end
  
end
