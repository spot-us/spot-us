namespace :credits do  
  desc "Move the old credits structure ot the new structure..."
  task :correct => :environment do
    puts %|------------------------------------------------------------------------------------------------|
    puts %|   Create effective credits for all users who need such entries... |
    puts %|------------------------------------------------------------------------------------------------|
    single_non_applied_credits = Credit.find(:all, :select=>"id, user_id, count(*) as cnt, amount, description", :group => 'user_id having cnt=1')
    single_credit_ids = single_non_applied_credits.map(&:id)
    
    effective_credits = Credit.find(:all, :select=>"user_id, sum(amount) as effective_credit", :conditions=>"id not in (#{single_credit_ids.join(',')})", :group=>"user_id having effective_credit>0")
    
    puts %|------------------------------------------------------------------------------------------------|
    puts %| Number of users with a single unallocated credit: #{single_non_applied_credits.length} |
    puts %| Number of users with new effective credits to be created created: #{effective_credits.length} |
    puts %|------------------------------------------------------------------------------------------------|
      
    # correct the donations
    donations = donations = Donation.find(:all, :conditions=>"credit_id is not null")
    puts %|------------------------------------------------------------------------------------------------|
    puts %|   Starting to process the donations with credits allocated... |
    puts %|------------------------------------------------------------------------------------------------|
    corrected_credits = [-1]
    user_ids = []
    processed_donations = 0
    non_processed_donations = 0
    donations.each do |donation|
      puts %|          Processing donation #{donation.id}...|
      user_ids << donation.user_id
      
      old_credit = Credit.find(:first, :conditions=>"user_id=#{donation.user_id} and amount=#{donation.amount} and id not in (#{corrected_credits.join(',')})", :order=>"created_at desc")
      active_credit = donation.credit
      if old_credit && active_credit
        active_credit.amount = old_credit.amount
        active_credit.cca_id = old_credit.cca_id
        active_credit.save
        old_credit.destroy
        processed_donations += 1
      else
        puts %|             --- Creating new credit for donation #{donation.id}...|
        active_credit = Credit.create(:user_id => donation.user_id, :description => "Applied to Pitches (#{donation.pitch_id})",
                        :amount => donation.amount)
        donation.credit.destroy if donation.credit
        donation.credit_id = active_credit.id
        donation.save
        processed_donations += 1
      end
      
      corrected_credits << active_credit.id if active_credit
    end
    
    puts %|------------------------------------------------------------------------------------------------|
    puts %| Number of donations: #{donations.length} |
    puts %| Number of users: #{user_ids.uniq.length} |
    puts %| Number of processed donations: #{processed_donations}|
    puts %| Number of unprocessed credits: #{Donation.find(:all, :conditions=>"credit_id is not null and credits.amount<0", :include => :credit ).length} | 
    puts %|------------------------------------------------------------------------------------------------|
    
    # delete all spotusdonations with amount-0
    SpotusDonation.delete_all('amount<=0')
    
    spotus_donations = SpotusDonation.find(:all, :conditions=>"credit_id is not null")
    puts %|------------------------------------------------------------------------------------------------|
    puts %|   Starting to process the spotus donations... |
    puts %|------------------------------------------------------------------------------------------------|
    user_ids = []
    processed_donations = 0
    non_processed_donations = 0
    spotus_donations.each do |spotus_donation|
      puts %|          Processing spotus_donation #{spotus_donation.id}...|
      user_ids << spotus_donation.user_id
      old_credit = Credit.find(:first, :conditions=>"user_id=#{spotus_donation.user_id} and amount=#{spotus_donation.amount} and id not in (#{corrected_credits.join(',')})", :order=>"created_at desc")
      active_credit = spotus_donation.credit
      if old_credit && active_credit
        active_credit.amount = old_credit.amount
        active_credit.cca_id = old_credit.cca_id
        active_credit.save
        old_credit.destroy
        processed_donations += 1
      else
        puts %|             --- Creating new credit for spotus_donation #{spotus_donation.id}...|
        active_credit = Credit.create(:user_id => spotus_donation.user_id, :description => "Donated to SpotUs",
                        :amount => spotus_donation.amount)
        spotus_donation.credit.destroy if spotus_donation.credit
        spotus_donation.credit_id = active_credit.id
        spotus_donation.save
        processed_donations += 1
      end
      
      corrected_credits << active_credit.id if active_credit
    end
    
    puts %|------------------------------------------------------------------------------------------------|
    puts %| Number of spotus donations: #{spotus_donations.length} |
    puts %| Number of users: #{user_ids.uniq.length} |
    puts %| Number of processed spotus donations: #{processed_donations}|
    puts %| Number of unprocessed credits for spotus donations: #{SpotusDonation.find(:all, :conditions=>"credit_id is not null and credits.amount<0", :include=>:credit).length} | 
    puts %|------------------------------------------------------------------------------------------------|
  
    puts %|------------------------------------------------------------------------------------------------|
    puts %|   Create effective credits for all users who need such entries... |
    puts %|------------------------------------------------------------------------------------------------|
    
    puts %|     Deleting unused credits... | 
    Credit.delete_all("id not in (#{corrected_credits.join(',')})")
    
    puts %|       Create effective credits for all users who need such entries... |
    effective_credits.each do |credit|
      puts %|             --- Creating effective credit entry for user #{credit.user ? credit.user.full_name : "Anonymous"}...|
      active_credit = Credit.create(:user_id => credit.user_id, :description => "Creating effective credit",
                      :amount => credit.effective_credit)
    end
    
  end
  
  desc "Test script for old credits (obsolete)..."
  task :test => :environment do
    donations = Donation.find(:all, :conditions=>"credit_id is not null")
    puts %|------------------------------------------------------------------------------------------------|
    puts %|   Starting to process the donations to clean the credits table... |
    puts %|------------------------------------------------------------------------------------------------|
    not_equal_donations_credits = 0
    nr_of_users_with_only_one_credit = 0
    nr_of_users_with_only_one_credit_from_cca = 0
    nr_of_users_with_only_two_credits = 0
    nr_of_users_with_only_two_credits_from_cca = 0
    user_ids = []
    donations.each do |donation|
      credits_per_user = Credit.find(:all, :conditions=>"user_id=#{donation.user_id}")
      credits_per_user_via_cca = Credit.find(:all, :conditions=>"user_id=#{donation.user_id} and cca_id is not null")
      nr_of_credits = credits_per_user.length
      diff_amount = donation.credit.amount+donation.amount
      user_ids << donation.user_id

      puts %|       ---------------------------------------------------------------|      
      puts %|          Processing donation #{donation.id}|
      puts %|       ---------------------------------------------------------------|
      puts %|             Pitch #{donation.pitch.headline.strip} |
      puts %|             User #{donation.user.full_name} | if donation.user
      puts %|             ---------------------------------------------------------|
      puts %|                   Number of credits for this users: #{nr_of_credits} |
      puts %|             ---------------------------------------------------------|
      puts %|             Amount $#{donation.amount} |
      puts %|             Credit Amount $#{donation.credit.amount} |
      puts %|             Difference $#{diff_amount} |
      puts %|       ---------------------------------------------------------------|
      
      if nr_of_credits == 2
        nr_of_users_with_only_one_credit += 1
        nr_of_users_with_only_one_credit_from_cca += 1 if credits_per_user.first.cca_id
      elsif nr_of_credits == 4
          nr_of_users_with_only_two_credits += 1
          nr_of_users_with_only_two_credits_from_cca += 1 if credits_per_user_via_cca.length==2
      end
      not_equal_donations_credits += 1 if diff_amount > 0
    end
    
    puts %| Number of donations: #{donations.length} |
    puts %| Number of donations not covered by the credit: #{not_equal_donations_credits} |
    puts %| Number of users: #{user_ids.uniq.length} |
    puts %| Number of users with only one credit: #{nr_of_users_with_only_one_credit} |
    puts %| Number of users with only one credit from cca: #{nr_of_users_with_only_one_credit_from_cca} |
    puts %| Number of users with only two credits: #{nr_of_users_with_only_two_credits} |
    puts %| Number of users with only two credits from cca: #{nr_of_users_with_only_two_credits_from_cca} |
    
  end
  
  task :show => :environment do
  
    users = User.find(:all, :order=>"last_name, first_name asc")
    users.each do |user|
      if user.total_credits>0
        puts %|       #{user.full_name} (#{user.id}) has total credits #{user.total_credits} |
      end
    end
    
    
  end
  
  
end