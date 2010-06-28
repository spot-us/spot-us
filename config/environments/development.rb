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
config.action_controller.perform_caching             = true
SslRequirement.disable_ssl_check = true
# Don't care if the mailer can't send
config.action_mailer.raise_delivery_errors = false

# use_gateway = false
use_gateway = true

if APP_CONFIG[:action_mailer].is_a?(Hash)
  # config.action_mailer.delivery_method = APP_CONFIG[:action_mailer][:delivery_method]
  # config.action_mailer.smtp_settings   = APP_CONFIG[:action_mailer][:smtp_settings]
end

ActiveMerchant::Billing::Base.mode = :test

config.to_prepare do
  if use_gateway && APP_CONFIG[:gateway].is_a?(Hash)
    Purchase.gateway = ActiveMerchant::Billing::AuthorizeNetGateway.new({
      :login    => APP_CONFIG[:gateway][:login],
      :password => APP_CONFIG[:gateway][:password],
      :test => true
    })
  else
    Purchase.gateway = ActiveMerchant::Billing::BogusGateway.new
  end
end

PAYPAL_POST_URL = "https://www.sandbox.paypal.com/cgi-bin/webscr"
PAYPAL_EMAIL = "info+s_1240233800_per@spot.us"
S3_BUCKET = APP_CONFIG[:s3_bucket][:development]

UPDATE_USER_TWITTER = false

FACEBOOK_CONSUMER_KEY    = APP_CONFIG[:facebook][:consumer_key]
FACEBOOK_CONSUMER_SECRET = APP_CONFIG[:facebook][:consumer_secret]
TWITTER_CONSUMER_KEY    = APP_CONFIG[:twitter][:consumer_key]
TWITTER_CONSUMER_SECRET = APP_CONFIG[:twitter][:consumer_secret]

