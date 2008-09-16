module EdgeCase
  module RSpecExpectationMatchers
    module ProvidesFor
      module ActiveRecord
        
        class ValidatesPresenceOf < BaseValidationMatcher

          def initialize(attribute, options = {})
            @attribute = attribute.to_sym
            @options = options
            @invalid_value = @options[:invalid_value] || nil
            @valid_value = @options[:valid_value] || nil
            @validation_err_msg = @options[:message] || ::ActiveRecord::Errors.default_error_messages[:blank]
          end

          def matches?(model)
            @model = model

            return false unless model.respond_to?(@attribute)
            # Collect the valid value if it wasn't already provided
            @valid_value = model.send(@attribute) if @valid_value.nil? and @invalid_value.nil?

            return false unless @options[:if].blank? or !!::ActiveRecord::Base.evaluate_condition(@options[:if], model)
            return false unless @options[:unless].blank? or !::ActiveRecord::Base.evaluate_condition(@options[:unless], model)

            # Set the attribute to it's invalid value
            model.send("#{@attribute.to_s}=".to_sym, @invalid_value)
            
            return false if model.valid?
            return false if model.errors.on(@attribute).blank?
            return false unless model.errors.on(@attribute).include?(@validation_err_msg)
            return true
          end

          def failure_message
            message = " - #{@model.class.to_s} does not validates presence of :#{@attribute} as expected."
            message << print_out_errors(@model)
          end

          def negative_failure_message
            message = " - #{@model.class.to_s} appears to validates presence of :#{@attribute}."
            message << print_out_errors(@model)
          end

          def description
            "validate presence of #{@attribute}"
          end

        end

        def validate_presence_of(attr, options = { })
          EdgeCase::RSpecExpectationMatchers::ProvidesFor::ActiveRecord::ValidatesPresenceOf.new(attr, options)
        end
        alias_method :require_presence_of, :validate_presence_of
        
      end
    end
  end
end