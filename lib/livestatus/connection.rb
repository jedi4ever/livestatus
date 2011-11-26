require "livestatus/handler"
require "livestatus/memoize"

module Livestatus

  class Connection
    extend Forwardable

    def_delegators :handler, :get, :command

    def initialize(config)
      @config = config.symbolize_keys!
    end

    def handler
      case @config[:uri]
      when /^https?:\/\//
        PatronHandler.new(self, @config)
      when /^unix:\/\//
        UnixHandler.new(self, @config)
      else
        raise ArgumentError, "unknown uri type: #{@config[:uri]}"
      end
    end

    memoize :handler
  end

end
