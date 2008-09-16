require 'spec'

require File.join(File.dirname(__FILE__), 'action_controller/route_matcher')

module EdgeCase
  module RSpecExpectationMatchers
    module ProvidesFor
      module ActionController
        
      end
    end
  end
end

if defined?(Spec::DSL)
  module Spec::DSL::Behaviour
    def it_should_render_template(template_name)
      it "should render template #{template_name}" do
        http_request

        response.should render_template(template_name)
      end
    end
  end
else
  module Spec::Example::Behaviour
    def it_should_render_template(template_name)
      it "should render template #{template_name}" do
        http_request

        response.should render_template(template_name)
      end
    end
  end  
end
module Spec
  module Rails
    module Matchers
      
      include EdgeCase::RSpecExpectationMatchers::ProvidesFor::ActionController
      
    end
  end
end