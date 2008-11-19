module NewsItemsHelper

  def options_for_sorting(news_type_name, selected)
    out = ""
    case news_type_name
      when "news_items"
        [["desc", "Newest"], ["asc", "Oldest"]].each do |(value, name)|
          selected_val = value == selected ? "selected='selected'" : nil
          out << "<option class='news_items tips pitches' value='#{value}' #{selected_val}>#{name}</option>"
        end
      when "tips"
        [["desc", "Newest"], ["asc","Oldest"], ["most_pledged","Most Pledged"]].each do |(value, name)|
          selected_val = value == selected ? "selected='selected'" : nil
          classes = %w{desc asc}.include?(value) ? "news_items tips pitches" : "tips"
          out << "<option class='#{classes}' value='#{value}' #{selected_val}>#{name}</option>"
        end
      when "pitches"
        [["desc", "Newest"], ["asc","Oldest"], ["almost_funded", "Almost Funded"], ["most_funded","Most Funded"]].each do |(value, name)|
          selected_val = value == selected ? "selected='selected'" : nil
          classes = %w{desc asc}.include?(value) ? "news_items tips pitches" : "pitches"
          out << "<option class='#{classes}' value='#{value}' #{selected_val}>#{name}</option>"
        end
    end
        
    out.to_s
  end
end
