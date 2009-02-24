# Sets up the Rails environment for Cucumber
ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + '/../../config/environment')
require 'cucumber/rails/world'
require 'cucumber/formatters/unicode' # Comment out this line if you don't want Cucumber Unicode support
Cucumber::Rails.use_transactional_fixtures
require 'cucumber/rails/rspec'
require 'webrat/rspec-rails'
require 'webrat'

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
    "#{dehumanize(name)}_path(#{instance})"
  end
end

World do |world|
  world.extend(HumanMethods)
  world.extend(HelperMethods)
end

Webrat.configure do |config|
  config.mode = :rails
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