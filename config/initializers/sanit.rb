ActionView::Base.sanitized_allowed_tags.replace %w(a b em i q blockquote strike strong tt u ul ol li br p img object embed param h2 h3)
ActionView::Base.sanitized_allowed_attributes.replace  %w(id type width height rel title alt href name value classid codebase allowscriptaccess src allownetworking allowfullscreen data type flashvars bgcolor) 

class String
  def sanitize(options={})
    ActionController::Base.helpers.sanitize(self, options)
  end
  
  def strip_html
    self.gsub(/(<[^>]+>|&nbsp;|\r|\n)/, "")
  end
  
  def strip_double_spaces
    self.gsub("<p>&nbsp;</p>", "")
  end

  def truncate_words(length = 30, end_string = '&hellip;')
    words = self.split()
    words[0..(length-1)].join(' ') + (words.length > length ? end_string : '')
  end
  
  def strip_and_shorten(length = 30, end_string = '&hellip;')
    self.strip_html.truncate_words(length, end_string)
  end
  
  def shorten_character_limit(length, end_string)
    self.length>length ? self[0..length].gsub(/\w+$/, '') + end_string : self
  end
  
  def strip_and_shorten_character_limit(length = 45, end_string = '')
    self.sanitize.simple_format.strip_html.shorten_character_limit(length, end_string).strip
  end
  
  def to_currency
    ActionController::Base.helpers.number_to_currency(self)
  end
  
  def simple_format(html_options={})
    ActionController::Base.helpers.simple_format(self, html_options={})
  end
  
end