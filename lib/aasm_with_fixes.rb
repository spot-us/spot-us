module AASM
  class StateMachine
    def clone
      klone = super
      klone.states = states.clone
      klone.events = events.clone
      klone
    end
  end
end

module AASMWithFixes
  def self.included(base)
    base.send(:include, AASM)
  end
end
