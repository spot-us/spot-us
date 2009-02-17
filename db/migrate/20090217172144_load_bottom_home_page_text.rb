class LoadBottomHomePageText < ActiveRecord::Migration
  def self.up
    SiteOption.create!(:key => :bottom_home_page_text, :value => "<h5 style=\"margin: 0pt;\">See our FAQ's for <a href=\"/pages/about#faq\"> Concerned Citizens, Reporters and News Organizations</a>. Spot.Us is a marketplace where all three come to collaborate.<p></p><p></p>Check out our <a href=\"http://blog.spot.us\">blog</a> join our <a href=\"http://www.facebook.com/home.php#/group.php?sid=b04b3406bd9281f4fe4df6c39efef5d5&amp;refurl=http%3A%2F%2Fwww.facebook.com%2Fs.php%3Fref%3Dsearch%26init%3Dq%26q%3Dspot.us%26sid%3Db04b3406bd9281f4fe4df6c39efef5d5&amp;gid=29554944739\">Facebook</a> or follow us on <a href=\"http://twitter.com/spotus\">Twitter</a>.</h5>")
  end

  def self.down
    if site_option = SiteOption.find_by_key(:bottom_home_page_text)
      site_option.destroy
    end
  end
end
