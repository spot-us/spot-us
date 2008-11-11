unless Rails.env.production?
  1.upto 22 do |count|
    Factory(:tip, :headline => "Tip Headline #{count}")
  end

  tips = Tip.find :all

  tips.each do |tip| 
    2.times do
      Factory(:pledge, :tip => tip, :amount => 25)
    end
  end


  1.upto 22 do |count|
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