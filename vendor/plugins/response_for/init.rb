require 'ardes/response_for'
ActionController::Base.send :include, Ardes::ResponseFor
ActionController::MimeResponds::Responder.send :include, Ardes::ResponseFor::Responder