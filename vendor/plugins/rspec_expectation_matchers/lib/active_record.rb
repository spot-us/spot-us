require 'spec'

require File.join(File.dirname(__FILE__), 'active_record/association_matcher')
require File.join(File.dirname(__FILE__), 'active_record/be_valid_matcher')
require File.join(File.dirname(__FILE__), 'active_record/base_validation_matcher')
require File.join(File.dirname(__FILE__), 'active_record/validates_acceptance_of')
require File.join(File.dirname(__FILE__), 'active_record/validates_confirmation_of')
require File.join(File.dirname(__FILE__), 'active_record/validates_length_of')
require File.join(File.dirname(__FILE__), 'active_record/validates_presence_of')
require File.join(File.dirname(__FILE__), 'active_record/validates_uniqueness_of')
require File.join(File.dirname(__FILE__), 'active_record/validates_inclusion_of')

module EdgeCase
  module RSpecExpectationMatchers
    module ProvidesFor
      module ActiveRecord
        
        # NOT YET IMPLEMENTED
        def validate_associated(associated_model, options = { })

        end

        def validate_exclusion_of(attr, options = { })

        end

        def validate_format_of(attr, options = { })

        end

        def validate_numericality_of(attr, options = { })

        end
        
      end
    end
  end
end

module Spec
  module Rails
    module Matchers
      
      include EdgeCase::RSpecExpectationMatchers::ProvidesFor::ActiveRecord
      
    end
  end
end
