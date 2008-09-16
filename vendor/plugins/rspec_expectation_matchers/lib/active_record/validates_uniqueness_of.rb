module EdgeCase
  module RSpecExpectationMatchers
    module ProvidesFor
      module ActiveRecord

        class ValidatesUniquenessOf < BaseValidationMatcher

          def initialize(attribute, options = {})
            @attribute = attribute.to_sym
            @options = options
            @invalid_value = @options[:invalid_value] || nil
            @valid_value = @options[:valid_value] || nil
          end

          def matches?(model)
            model.save if model.new_record?

            @model = model.class.new(model.attributes)  
            return !@model.valid? && @model.errors.invalid?(@attribute)
          end

          def failure_message
            message = " - #{@model.class.to_s} does not validates uniqueness of :#{@attribute} as expected."
            class_count = @model.class.count
            message << "\n   There were #{class_count} records present in the database, but none matched your uniqueness validation.  Try saving a record with the unique attribute first."

            message << print_out_errors(@model)
          end

          def negative_failure_message
            message = " - #{@model.class.to_s} appears to validates uniqueness of :#{@attribute}."
            message << print_out_errors(@model)
          end

          def description
            "validate uniqueness of #{@attribute}"
          end

        end

        def validate_uniqueness_of(attr, options = { })
          EdgeCase::RSpecExpectationMatchers::ProvidesFor::ActiveRecord::ValidatesUniquenessOf.new(attr, options)
        end
        
      end
    end
  end
end