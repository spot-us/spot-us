module EdgeCase
  module RSpecExpectationMatchers
    module ProvidesFor
      module ActiveRecord
        
        class BaseValidationMatcher
          attr_reader :attribute
          attr_reader :options
          attr_reader :model
          attr_reader :invalid_value
          attr_reader :valid_value

          protected
            def print_out_errors(model)
              unless model.nil? or model.errors.empty?
                message = "\n   There were #{model.errors.size} validation errors were present:\n"
                model.errors.full_messages.each do |full_message|
                  message << "     - #{full_message}"
                end
                return message
              end

              return ''
            end
        end
        
      end
    end
  end
end