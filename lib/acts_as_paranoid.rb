module Paranoid
  module ActiveRecord
    module ClassMethods
      protected
      def validate_find_options_with_deleted(options)
        options.assert_valid_keys [:conditions, :group, :include, :joins, :limit, :offset, :order, :select, :readonly, :with_deleted, :from]
      end
    end
  end
end