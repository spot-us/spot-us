module EdgeCase
  module RSpecExpectationMatchers
    module ProvidesFor
      module ActionController

        class RouteMatcher
          attr_reader :route_hash
          attr_reader :desired_url
          attr_reader :generated_route

          def initialize(desired_url = {}, route_hash = {})
            @route_hash = route_hash[:from]
            @desired_url = desired_url
          end

          def matches?(controller)
            @controller = controller

            # Ensure that routes are loaded
            ::ActionController::Routing::Routes.reload if ::ActionController::Routing::Routes.empty?

            routes = ::ActionController::Routing::Routes.generate(route_hash)
            # Rails 1.1.6
            @generated_route = routes[0] if routes.is_a?(Array)
            # Rails 1.2
            @generated_route = routes if routes.is_a?(String)

            return (generated_route == desired_url)
          end

          def failure_message
            "- expected '#{@desired_url}' but received '#{@generated_route}'"
          end

          def negative_failure_message
            "- expected route to fail"
          end

          def description
            "map {#{make_route_hash_pretty(@route_hash)}} to '#{@generated_route}'"
          end

          private
            def make_route_hash_pretty(route_hash= {})
              route_hash_array = []

              route_hash.each do |key,value|
                route_hash_array << ":#{key} => #{value}"
              end

              return route_hash_array.join(', ')
            end

        end

        def map_route(desired_url = '', route_hash = {})
          EdgeCase::RSpecExpectationMatchers::ProvidesFor::ActionController::RouteMatcher.new(desired_url, route_hash)
        end
        
      end
    end
  end
end