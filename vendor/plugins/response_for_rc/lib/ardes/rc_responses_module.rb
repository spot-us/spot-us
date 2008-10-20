module Ardes
  # Just like ResponsesModule, but also handles the :except, :only options
  module RcResponsesModule
    include Ardes::ResourcesController::IncludeActions
    
    def self.extended(mixin)
      mixin.extend Ardes::ResponsesModule
    end
    
    # as well as undefing an exlcuded action from the dup mixin, we
    # also remove its response
    def remove_action_method(action)
      undef_method action
      remove_response_for action
    end
    
    # when we dup, we need to copy our action_responses
    def dup
      returning super do |mixin|
        mixin.instance_variable_set('@action_responses', action_responses.dup)
      end
    end    
  end
end