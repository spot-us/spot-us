module Sanitizy
  class Sanitizer < HTML::WhiteListSanitizer
    attr_reader :columns
    def initialize(*columns)
      @columns = columns
    end
    [:attributes,:tags].each do |acc|
      class_eval <<-CODE
        alias default_allowed_#{acc} allowed_#{acc}
        def allowed_#{acc}
          @allowed_#{acc} ||= default_allowed_#{acc}.dup
        end
        def allowed_#{acc}=(#{acc})
          @allowed_#{acc} = Set.new(#{acc})
        end
      CODE
    end
  end

  def self.included(base)
    base.extend(ClassMethods)
    base.before_save :sanitize_declared_columns
    base.class_inheritable_accessor :sanitizy_columns
    base.sanitizy_columns = {}
  end

  module ClassMethods
    def cleanse_columns(*columns, &block)
      columns.each do |column|
        name = sanitizer_attr_name_for(column)
        class_eval <<-CODE
          def #{name}
            self.class.sanitizy_columns["#{column}"]
          end
          def #{name}=(sanitizer)
            self.class.sanitizy_columns["#{column}"] = sanitizer
          end
        CODE
      end

      sanitizer = Sanitizy::Sanitizer.new *columns
      yield sanitizer
      columns.each do |column|
        self.sanitizy_columns[column.to_s] = sanitizer
      end
      sanitizer
    end
    alias cleanse_column cleanse_columns

    def sanitizer_attr_name_for(column)
      "#{column}_sanitizer"
    end
  end

  def sanitize_declared_columns
    self.class.sanitizy_columns.each do |column, sanitizer|
      options = {
        :tags => sanitizer.allowed_tags.to_a,
        :attributes => sanitizer.allowed_attributes.to_a
      }
      sanitized = sanitizer.sanitize(self.send(column), options)
      self.send("#{column}=", sanitized)
    end
  end
end

