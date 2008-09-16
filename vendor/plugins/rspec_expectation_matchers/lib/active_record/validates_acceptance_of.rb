module EdgeCase
  module RSpecExpectationMatchers
    module ProvidesFor
      module ActiveRecord

        class ValidatesAcceptanceOf < BaseValidationMatcher

          def initialize(attribute, options = {})
            @attribute = attribute.to_sym
            @options = options
            @invalid_value = false
            @valid_value = true
          end

          def matches?(model)
            @model = model

            return false unless model.respond_to?(@attribute)

            # Set the attribute to it's invalid value
            model.send("#{@attribute.to_s}=".to_sym, @invalid_value)

            return (!model.valid? and !model.errors.on(@attribute).blank?)
          end

          def failure_message
            message = " - #{@model.class.to_s} does not validates acceptance of :#{@attribute} as expected."
            message << print_out_errors(@model)
          end

          def negative_failure_message
            message = " - #{@model.class.to_s} appears to validates acceptance of :#{@attribute}."
            message << print_out_errors(@model)
          end

          def description
            "validate presence of #{@attribute}"
          end

        end

        def validate_acceptance_of(attr, options = { })
          EdgeCase::RSpecExpectationMatchers::ProvidesFor::ActiveRecord::ValidatesAcceptanceOf.new(attr, options)
        end
        
      end
    end
  end
end