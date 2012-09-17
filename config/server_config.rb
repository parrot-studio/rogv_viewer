# coding: utf-8
require 'yaml'

module ROGv
  class ServerConfig

    CONFIGS = lambda do
      data = YAML.load(File.read(File.join(PADRINO_ROOT, 'config', 'config.yml')))
      data[PADRINO_ENV].freeze
    end.call

    class << self
      def memcache_server
        return unless CONFIGS[:memcache]
        CONFIGS[:memcache][:server]
      end

      def memcache_port
        return unless CONFIGS[:memcache]
        CONFIGS[:memcache][:port]
      end

      def memcache_url
        "#{memcache_server}:#{memcache_port}"
      end

      def memcache_header
        return unless CONFIGS[:memcache]
        CONFIGS[:memcache][:header]
      end

      def use_cache?
        CONFIGS[:use_cache] ? true : false
      end

      def server_name
        CONFIGS[:server_name]
      end

      def db_name
        return unless CONFIGS[:db]
        CONFIGS[:db][:name]
      end

      def db_user
        return unless CONFIGS[:db]
        CONFIGS[:db][:user]
      end

      def db_pass
        return unless CONFIGS[:db]
        CONFIGS[:db][:pass]
      end

      def result_size
        val = CONFIGS[:result_size].to_i
        return 6 if val < 1
        val
      end

      def update_accept_host
        CONFIGS[:update_accept_host] || 'localhost'
      end
    end

  end
end