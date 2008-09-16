module EdgeCase
  module RSpecExpectationMatchers
    module ProvidesFor
      module ActiveRecord

        class ValidatesConfirmationOf < BaseValidationMatcher

          def initialize(attribute, options = {})
            @attribute = attribute.to_sym
            @options = options
            @invalid_value = @options[:invalid_value] || nil
          end

          def matches?(model)
            @model = model

            return false unless model.respond_to?(@attribute)

            # Set the attribute to it's invalid value
            model.send("#{@attribute.to_s}_confirmation=".to_sym, @invalid_value)

            return (!model.valid? and !model.errors.on("#{@attribute.to_s}_confirmation".to_sym).blank?)
          end

          def failure_message
            message = " - #{@model.class.to_s} does not validates confirmation of :#{@attribute} as expected."
            message << print_out_errors(@model)
          end

          def negative_failure_message
            message = " - #{@model.class.to_s} appears to validates confirmation of :#{@attribute}."
            message << print_out_errors(@model)
          end

          def description
            "validate confirmation of #{@attribute}"
          end

        end

        def validate_confirmation_of(attr, options = { })
          EdgeCase::RSpecExpectationMatchers::ProvidesFor::ActiveRecord::ValidatesConfirmationOf.new(attr, options)
        end
        alias_method :require_confirmation_of, :validate_confirmation_of
      
      end
    end
  end
end