module Sanitizy

  def self.included(base)
    base.extend(ClassMethods)
  end

  def cleanse(*args)
    args.each do |sym|
      self.send("#{sym}=", self.class.sanitizer.sanitize(self.send(sym)))
    end
  end

  module ClassMethods
    def sanitizer 
      @white_list_sanitizer ||= HTML::WhiteListSanitizer.new
    end
  end

end
