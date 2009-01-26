module Sanitizy
  def self.included(base)
    base.extend(ClassMethods)
    base.before_save :sanitize_declared_columns
    base.class_inheritable_array :sanitizy_columns
  end

  module ClassMethods
    def cleanse_columns(*columns, &block)
      self.sanitizy_columns = columns
      sanitizy_columns.each do |column|
        class_inheritable_accessor sanitizer_attr_name_for(column)
        send("#{self.sanitizer_attr_name_for(column)}=", HTML::WhiteListSanitizer.new)
        yield sanitizer_for(column)
      end
    end

    def sanitizer_attr_name_for(column)
      "#{column}_sanitizer"
    end

    def sanitizer_for(column)
      send(sanitizer_attr_name_for(column))
    end
  end

  def sanitize_declared_columns
    self.class.sanitizy_columns.each do |column, options|
      self.send("#{column}=", self.class.sanitizer_for(column).sanitize(self.send(column)))
    end
  end
end

