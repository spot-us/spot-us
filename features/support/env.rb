# Sets up the Rails environment for Cucumber
ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + '/../../config/environment')
require 'cucumber/rails/world'
require 'webrat/rails'
require 'cucumber/rails/rspec'
Cucumber::Rails.use_transactional_fixtures

module HumanMethods
  def dehumanize(string)
    string.gsub(/\W+/,'_')
  end

  def human_route(name)
    send("#{dehumanize(name).sub(/^home$/,'root')}_path")
  end
  
  def human_route_for_current(name)
    instance = name.split(' ').last
    instance = "@#{instance}"
    send("#{dehumanize(name)}_path", instance_variable_get(instance))
  end
end

World do |world|
  world.extend(HumanMethods)
  world.extend(HelperMethods)
end

module HelperMethods
  def set_instance_variable(name, value)
    instance_variable_name = "@#{name}"
    instance_variable_set(instance_variable_name, value)
  end
  def get_instance_variable(name)
    instance_variable_name = "@#{name}"
    instance_variable_get(instance_variable_name)
  end
end

Webrat.configure do |config|
  config.mode = :rails
end
