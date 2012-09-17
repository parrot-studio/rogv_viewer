# coding: utf-8
module ROGv
  module DataCache

    def cache_enable?
      ServerConfig.use_cache? ? true : false
    end

    def cache_time
      case PADRINO_ENV.to_sym
      when :production
        1.days
      else
        60
      end
    end

    def get_with_cache(name, &b)
      return b.call unless cache_enable?
      cache("#{ServerConfig.memcache_header}_#{name}", :expires_in => cache_time, &b)
    end

    def result_dates
      get_with_cache("result_dates") do
        WeeklyResult.date_list
      end
    end

    def expire_all_cache
      result_dates.each do |d|
        ['result_view_for','call_view_for'].each do |k|
          expire("#{ServerConfig.memcache_header}_#{k}_#{d}")
        end
      end

      ['result_dates','index_view'].each do |k|
        expire("#{ServerConfig.memcache_header}_#{k}")
      end
    end

  end
end
