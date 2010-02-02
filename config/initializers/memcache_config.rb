module SpotUs
  module Cache
    
    def self.initialize!
      cache_options = { :namespace => ['spotus_', Rails.env].join, :show_backtraces => true }
      Object.const_set :CACHE, Memcached::Rails.new(::MEMCACHE_SERVERS, cache_options)
      ActionController::Base.cache_store = :mem_cache_store, ::MEMCACHE_SERVERS, cache_options
      Object.const_set :RAILS_CACHE, ActionController::Base.cache_store
    end
    
  end
end

class Memcached
  class Rails
    def get_multi(keys, raw=false)
      get_orig(keys, !raw)
    rescue NotFound
      []
    end
  end
end

CACHE_AVAILABLE                       = true
CACHE_TIMEOUT                         = 30.minutes