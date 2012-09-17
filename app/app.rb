# coding: utf-8
module ROGv
  class Viewer < Padrino::Application
    register Padrino::Rendering
    register Padrino::Mailer
    register Padrino::Helpers

    disable :sessions

    register Padrino::Cache
    enable :caching
    set :cache, Padrino::Cache::Store::Memcache.new(
      ::Dalli::Client.new(ServerConfig.memcache_url, :exception_retry_limit => 1))

    include DataCache

    ##
    # Application configuration options
    #
    # set :raise_errors, true       # Raise exceptions (will stop application) (default for test)
    # set :dump_errors, true        # Exception backtraces are written to STDERR (default for production/development)
    # set :show_exceptions, true    # Shows a stack trace in browser (default for development)
    # set :logging, true            # Logging in STDOUT for development and file for production (default only for development)
    # set :public_folder, "foo/bar" # Location for static assets (default root/public)
    # set :reload, false            # Reload application files (default in development)
    # set :default_builder, "foo"   # Set a custom form builder (default 'StandardFormBuilder')
    # set :locale_path, "bar"       # Set path for I18n translations (default your_app/locales)
    # disable :sessions             # Disabled sessions by default (enable if needed)
    # disable :flash                # Disables sinatra-flash (enabled by default if Sinatra::Flash is defined)
    # layout  :my_layout            # Layout can be in views/layouts/foo.ext or views/foo.ext (default :application)
    #

    not_found do
      render :not_found, :layout => :application
    end

    error do
      render :error, :layout => :application
    end

    private

    def post_action
      return 403 unless ServerConfig.update_accept_host == request.host
      yield
    end

    def date_action
      date = params[:date]
      redirect url_for(:index) unless date
      redirect url_for(:index) unless result_dates.include?(date)
      yield(date)
    end

  end
end