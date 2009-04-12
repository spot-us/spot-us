module DonationsHelper
  def donate_text(news_item)
    if current_user && current_user.has_donated_to?(news_item)
      'DONATE MORE &raquo;'
    else
      'OR DONATE ANOTHER AMOUNT &raquo;' 
    end
  end
end
