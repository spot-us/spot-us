ActiveRecord::Base.send :include, CacheConcerns::ModelMethods
ActionMailer::Base.send :include, CacheConcerns::ModelMethods