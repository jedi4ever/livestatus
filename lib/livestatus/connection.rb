require "livestatus/handler"

module Livestatus

  class Connection
    attr_accessor :handler

    def initialize(uri)
      case uri
      when /^https?:\/\//
        @handler = PatronHandler.new(uri)
      else
        raise AttributeError, "unknown uri type: #{uri}"
      end
    end

    def get(table, headers = {})
      handler.get(table, headers)
    end

    def command(cmd, time = nil)
      handler.command(cmd, time)
    end
  end

end
