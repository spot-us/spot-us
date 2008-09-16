require File.join(File.dirname(__FILE__), 'base_validation_matcher')

module EdgeCase
  module RSpecExpectationMatchers
    module ProvidesFor
      module ActiveRecord

        # From http://opensoul.org/2007/4/18/rspec-model-should-be_valid
        class BeValid < BaseValidationMatcher

          def matches?(model)
            @model = model
            @model.valid?
          end

          def failure_message
            "- #{@model.class} was invalid."
            print_out_errors(@model)
          end

          def negative_failure_message
            "- #{@model.class} was valid."
            print_out_errors(@model)
          end

          def description
            "be valid"
          end

        end

        def be_valid
          EdgeCase::RSpecExpectationMatchers::ProvidesFor::ActiveRecord::BeValid.new
        end
        
      end
    end
  end
end