module EdgeCase
  module RSpecExpectationMatchers
    module ProvidesFor
      module ActiveRecord

        class ValidatesInclusionOf < BaseValidationMatcher
          def derive_invalid_value_from_enumerable(e)
            if e.is_a?(Range)
              if e.first > e.last # somebody put in (3..1) instead of (1..3)
                e.first.to_i.next
              else
                e.last.to_i.next
              end
            elsif e.first.is_a?(Numeric)
              e.inject(0) { |sum,element| sum += element.respond_to?(:abs) ? element.abs : 0 }
            elsif e.first.is_a?(String)
              e.join('|') + Time.now.to_s
            end
          end

          def initialize(attribute, options = {})
            @attribute = attribute.to_sym
            @options = options
            @in = @options[:in] || []
            @in_values_as_sentence = @in.first.to_s + ', ..., ' + @in.last.to_s
            @validation_err_msg = @options[:message] || ::ActiveRecord::Errors.default_error_messages[:inclusion]
            
            @invalid_value = @options[:invalid_value] || derive_invalid_value_from_enumerable(@in)
            @valid_value = @options[:valid_value] || @in.first
          end

          def matches?(model)
            @model = model

            return false unless model.respond_to?(@attribute)

            model.send("#{@attribute.to_s}=".to_sym, @invalid_value)

            if model.valid?
              # The model was valid when passed an invalid value.
              return false 
            end

            if model.errors.on(@attribute).blank? || !model.errors.on(@attribute).include?(@validation_err_msg)
              # Model was invalid but there were no errors on the attribute that is being testing.
              return false 
            end

            @in.each do |valid_value|
              model.send("#{@attribute.to_s}=".to_sym, valid_value)
              model.valid?

              if model.errors.on(@attribute) && model.errors.on(@attribute).include?(@validation_err_msg)
                return false
              end
            end

            return true
          end

          def failure_message
            message = " - #{@model.class.to_s} does not validates inclusion of :#{@attribute} in #{@in_values_as_sentence} as expected."
            message << print_out_errors(@model)
          end

          def negative_failure_message
            message = " - #{@model.class.to_s} appears to validates inclusion of :#{@attribute} in #{@in_values_as_sentence}."
            message << print_out_errors(@model)
          end

          def description
            "validate inclusion of #{@attribute} in #{@in_values_as_sentence}"
          end

        end

        # currently does not support :if option
        def validate_inclusion_of(attr, options = { })
          EdgeCase::RSpecExpectationMatchers::ProvidesFor::ActiveRecord::ValidatesInclusionOf.new(attr, options)
        end
        alias_method :require_inclusion_of, :validate_inclusion_of

      end
    end
  end
end
