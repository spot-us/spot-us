config.action_controller.consider_all_requests_local = true
config.action_controller.perform_caching = false
config.action_mailer.raise_delivery_errors = true
config.action_view.debug_rjs = true
config.action_view.cache_template_loading = false
config.cache_classes = false
config.whiny_nils = true
SslRequirement.disable_ssl_check = true

if APP_CONFIG[:action_mailer].is_a?(Hash)
  config.action_mailer.delivery_method = APP_CONFIG[:action_mailer][:delivery_method]
  config.action_mailer.smtp_settings   = APP_CONFIG[:action_mailer][:smtp_settings]
end

config.to_prepare do
  if APP_CONFIG[:gateway].is_a?(Hash)
    Purchase.gateway = ActiveMerchant::Billing::AuthorizeNetGateway.new({
      :login    => APP_CONFIG[:gateway][:login],
      :password => APP_CONFIG[:gateway][:password],
      :test => true
    })
  else
    ActiveMerchant::Billing::Base.mode = :test
    Purchase.gateway = ActiveMerchant::Billing::BogusGateway.new
  end
end
