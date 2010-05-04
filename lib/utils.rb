module Utils
  def strip_html(text)
     text.gsub(/<\/?[^>]*>/, "")
  end
end