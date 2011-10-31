require "livestatus/handler"

module Livestatus

  class Connection
    def initialize(uri)
      @uri = uri
    end

    def get(table, headers = {})
      handler.get(table, headers)
    end

    def command(cmd, time = nil)
      handler.command(cmd, time)
    end

    def handler
      @handler ||= case @uri
                   when /^https?:\/\//
                     PatronHandler.new(@uri)
                   else
                     raise AttributeError, "unknown uri type: #{@uri}"
                   end
    end
  end

end
