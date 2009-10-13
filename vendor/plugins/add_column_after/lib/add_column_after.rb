module BrionesAndCo
  module ActiveRecord
    module ConnectionAdapters
      module AddColumnAfter
        
        def add_column_options!(sql, options) #:nodoc:
          sql << " DEFAULT #{quote(options[:default], options[:column])}" if options_include_default?(options)
          sql << " NOT NULL" if options[:null] == false
          sql << " AFTER #{options[:after]}" if options.include?(:after)
        end
        
      end
    end
  end
end