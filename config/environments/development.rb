# Settings specified here will take precedence over those in config/environment.rb

# In the development environment your application's code is reloaded on
# every request.  This slows down response time but is perfect for development
# since you don't have to restart the webserver when you make code changes.
config.cache_classes = false

# Log error messages when you accidentally call methods on nil.
config.whiny_nils = true

# Show full error reports and disable caching
config.action_controller.consider_all_requests_local = true
config.action_view.debug_rjs                         = true
config.action_controller.perform_caching             = false

# Don't care if the mailer can't send
config.action_mailer.raise_delivery_errors = false

# use_gateway = false
use_gateway = true

config.to_prepare do
  if use_gateway && APP_CONFIG['gateway'].is_a?(Hash)
    Purchase.gateway = ActiveMerchant::Billing::AuthorizeNetGateway.new({
      :login    => APP_CONFIG['gateway']['login'],
      :password => APP_CONFIG['gateway']['password'],
      :test => true
    })
  else
    ActiveMerchant::Billing::Base.mode = :test
    Purchase.gateway = ActiveMerchant::Billing::BogusGateway.new
  end
end

