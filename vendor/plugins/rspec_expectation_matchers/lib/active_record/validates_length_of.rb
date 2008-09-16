module EdgeCase
  module RSpecExpectationMatchers
    module ProvidesFor
      module ActiveRecord

        class ValidatesLengthOf < BaseValidationMatcher
          attr_reader :in
          attr_reader :minimum
          attr_reader :maximum
          attr_reader :length_check

          def initialize(attribute, options = {})
            @attribute = attribute.to_sym
            @options = options

            @valid_value = @options[:valid_value] || nil
            @in = @options[:in] || @options[:within] || nil
            @minimum = @options[:minimum] || nil
            @maximum = @options[:maximum] || nil
            @invalid_value = @options[:invalid_value] || nil

            if @invalid_value.nil?
              if @minimum
                @invalid_value = 'r' * (@minimum - 1)
              elsif @maximum
                @invalid_value = 'r' * (@maximum + 1)
              elsif @in
                @invalid_value = 'r' * (@in.last + 1)
              end
            end
          end

          def matches?(model)
            @model = model

            return false unless model.respond_to?(@attribute)

            # Collect the valid value if it wasn't already provided
            @valid_value = model.send(@attribute) if @valid_value.nil? and @invalid_value.nil?

            # Set the attribute to it's invalid value
            model.send("#{@attribute.to_s}=".to_sym, @invalid_value)

            return (!model.valid? and !model.errors.on(@attribute).blank?)
          end

          def failure_message
            message = " - #{@model.class.to_s} does not validates length of :#{@attribute} #{message_range} as expected."
            message << print_out_errors(@model)
          end

          def negative_failure_message
            message = " - #{@model.class.to_s} appears to validates length of :#{@attribute} #{message_range}."
            message << print_out_errors(@model)
          end

          def description
            "validate length of #{@attribute}"
          end

          private
            def message_range
              return "with a minimum length of #{@minimum}" if @minimum
              return "with a maximum length of #{@maximum}" if @maximum
              return "with a length between #{@in.first} and #{@in.last}" if @in
            end

        end

        def validate_length_of(attr, options = { })
          EdgeCase::RSpecExpectationMatchers::ProvidesFor::ActiveRecord::ValidatesLengthOf.new(attr, options)
        end
        alias_method :validate_size_of, :validate_length_of
        
      end
    end
  end
end