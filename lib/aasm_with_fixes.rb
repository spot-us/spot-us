module AASMWithFixes
  def self.included(base)
    base.send(:include, AASM)
    base.module_eval do
      class << self
        def inherited(child)
          AASM::StateMachine[child] = AASM::StateMachine[self].clone
          AASM::StateMachine[child].events = AASM::StateMachine[self].events.clone
          super
        end
      end
    end
  end
end