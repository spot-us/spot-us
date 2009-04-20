config.action_controller.consider_all_requests_local = true
config.action_controller.perform_caching = true
config.action_mailer.raise_delivery_errors = false
config.action_view.debug_rjs = true
config.cache_classes = false
config.whiny_nils = true
config.action_mailer.perform_deliveries = false
SslRequirement.disable_ssl_check = true

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
