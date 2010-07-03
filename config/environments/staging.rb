config.action_controller.consider_all_requests_local = true
config.action_controller.perform_caching = true
config.action_mailer.raise_delivery_errors = false
config.action_view.debug_rjs = true
config.cache_classes = false
config.whiny_nils = true
SslRequirement.disable_ssl_check = false

if APP_CONFIG[:action_mailer].is_a?(Hash)
  config.action_mailer.delivery_method = APP_CONFIG[:action_mailer][:delivery_method]
  config.action_mailer.smtp_settings   = APP_CONFIG[:action_mailer][:smtp_settings]
end

ActiveMerchant::Billing::Base.mode = :test
config.to_prepare do
  if APP_CONFIG[:gateway].is_a?(Hash)
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
S3_BUCKET = APP_CONFIG[:s3_bucket][:staging]

UPDATE_USER_TWITTER = false

FACEBOOK_CONSUMER_KEY    = APP_CONFIG[:facebook][:consumer_key]
FACEBOOK_CONSUMER_SECRET = APP_CONFIG[:facebook][:consumer_secret]
TWITTER_CONSUMER_KEY    = APP_CONFIG[:twitter][:consumer_key]
TWITTER_CONSUMER_SECRET = APP_CONFIG[:twitter][:consumer_secret]