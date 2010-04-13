#this is global key and can be used on all our domain.
#But there is facility in ReCaptcha to generate muliple keys for different domains

ENV['RECAPTCHA_PUBLIC_KEY'] = APP_CONFIG[:recaptcha][:public_key]
ENV['RECAPTCHA_PRIVATE_KEY'] = APP_CONFIG[:recaptcha][:private_key]