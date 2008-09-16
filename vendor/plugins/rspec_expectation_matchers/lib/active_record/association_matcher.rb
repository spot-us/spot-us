module EdgeCase
  module RSpecExpectationMatchers
    module ProvidesFor
      module ActiveRecord
        
        # From Brandon Keepers post on March 2nd
        class AssociationMatcher
          
          def initialize(type, name, options = {})
            @type = type
            @name = name
            @options = options
            @class_name = @options[:class_name] || (@options[:source] ? @options[:source].to_s.classify : @name.to_s.singularize.camelize)
          end

          def matches?(model)
            @model = model
            @association = model.class.reflect_on_association(@name)
            return false if @association.nil?
            # Bad has many through!  No lunch for you
            @class_name = @association.class_name if @options.has_key?(:through) 
            # Assume we don't wish to consider the options if none are provided
            @options = @association.options if @options.blank?
            @association.macro == @type && @association.class_name == @class_name && @association.options == @options
          end

          def failure_message
            "expected #{model.inspect} to have a #{type} association called :#{name}\n\n but found the following:\n\n #{association.inspect}"
          end

          def description
            "have a #{type} association called :#{name}"
          end

          private
            attr_reader :type, :name, :model, :association

        end

        def have_association(type, name, options = {})
          EdgeCase::RSpecExpectationMatchers::ProvidesFor::ActiveRecord::AssociationMatcher.new(type, name, options)
        end

        def belong_to(name, options = {})
          EdgeCase::RSpecExpectationMatchers::ProvidesFor::ActiveRecord::AssociationMatcher.new(:belongs_to, name, options)
        end

        def have_one(name, options = {})
          EdgeCase::RSpecExpectationMatchers::ProvidesFor::ActiveRecord::AssociationMatcher.new(:has_one, name, options)
        end

        def have_many(name, options = {})
          EdgeCase::RSpecExpectationMatchers::ProvidesFor::ActiveRecord::AssociationMatcher.new(:has_many, name, options)
        end

        def have_and_belong_to_many(name, options = {})
          EdgeCase::RSpecExpectationMatchers::ProvidesFor::ActiveRecord::AssociationMatcher.new(:has_and_belongs_to_many, name, options)
        end
        
      end
    end
  end
end
