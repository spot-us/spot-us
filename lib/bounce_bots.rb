module BounceBots
  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    def bounce_bots(*field_path, &block)
      before_filter :bounce_bot

      cattr_accessor :bounce_field_path
      cattr_accessor :bounce_block
      self.bounce_field_path = field_path
      self.bounce_block = block if block_given?
    end
  end

  protected

  def bounce_bot
    parents = bounce_field_path[0..-2]
    field = bounce_field_path.last
    bot_check = parents.inject(params) {|p, parent| p[parent] || {}}.delete(field)
    bounce_block and return false if bot_check.blank?
    true
  end
end
