require "livestatus/handler"

module Livestatus

  class Connection
    extend Forwardable

    def_delegators :handler, :get, :command

    def initialize(config)
      @config = config.symbolize_keys!
    end

    def handler
      @handler ||= handler!
    end

    def handler!
      case @config[:uri]
      when /^https?:\/\//
        PatronHandler.new(self, @config)
      when /^unix:\/\//
        UnixHandler.new(self, @config)
      else
        raise AttributeError, "unknown uri type: #{@config[:uri]}"
      end
    end
  end

end
