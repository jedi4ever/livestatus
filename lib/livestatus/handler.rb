module Livestatus

  class HandlerException < StandardError; end

  class BaseHandler
    def get(table_name, options = {})
      query(:get, table_name.to_s, options)
    end

    def command(cmd, time = nil)
      time = Time.now.to_i unless time
      query(:command, "[#{time}] #{cmd}")
    end
  end

end

Dir["#{File.dirname(__FILE__)}/handler/*.rb"].each do |path|
  require "livestatus/handler/#{File.basename(path, '.rb')}"
end
