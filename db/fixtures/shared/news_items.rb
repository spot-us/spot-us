unless Rails.env.production?
  count = 0
  10.times do
    count = count + 1
    Factory(:tip, :headline => "Tip Headline #{count}")
  end
  tips = Tip.find :all
  tips.each do |tip| 
    2.times do
    Factory(:pledge, :tip => tip, :amount => 25)
    end
  end
  count = 0
  10.times do 
    count = count + 1
    Factory(:pitch, :headline => "Pitch Headline #{count}")
  end
  pitches = Pitch.find :all
  pitches.each do |pitch| 
    2.times do 
      Factory(:donation, :pitch => pitch, :amount => 10, :status => 'paid')
    end
    2.times do 
      Factory(:donation, :pitch => pitch, :amount => 10)
    end
  end
end