# This should ultimately be the preferred module for cache methods
module CacheConcerns
  
  def self.reduce_key(key)
    final_key = ActiveSupport::Cache.expand_cache_key(key)
    #final_key = convert_to_ascii(final_key.gsub(" ",""))
    Digest::SHA1.hexdigest(final_key)
  end
  
  module ControllerMethods
    
    def self.included(klass)
      klass.helper_method :reduce_key
    end
    
    def unless_cache_exists_for(key, options={}, &block)
      must_perform = options.delete(:always_when) || false
      block.call if !fragment_exist?(CacheConcerns.reduce_key(key), options) || must_perform
    rescue Memcached::Error
      block.call
    end
    
    def should_clear_cache?
      params[:clear_cache] || session[:clear_cache] = false
    end
    
  end
  
  module ModelMethods
    
    def self.included(klass)
      klass.extend self
    end
    
    def having_cache(key, options = {}, &block)
      options.assert_valid_keys(:using, :expires_in, :force)
      options.reverse_merge! :using => {}
      key_options = options[:using].stringify_keys!.keys.map(&:to_s).sort.map { |k| [k, options[:using][k]] * '=' } * '&'
      compressed_key = CacheConcerns.reduce_key "#{key}:#{key_options}"
      val = nil
      if Rails.cache.exist?(compressed_key) && !options[:force]
        #val = Rails.cache.fetch(compressed_key, options, &block)
        val = Rails.cache.read(compressed_key)
        val = nil if (val && val == "nil_value")
      else
        # execute the block 
        val = block.call
        val = "nil_value" if !val
        Rails.cache.write(compressed_key, val, options)
        val = nil if val == "nil_value"
      end
      return val
    rescue Memcached::Error
      block.call
    end
    
  end
  
end