module Livestatus

  class HandlerException < StandardError; end

  class BaseHandler
    def get(table_name, options = {})
      data = query(:get, table_name.to_s, options)

      if options.include?(:columns)
        columns = options[:columns].split(" ")
      else
        columns = data.delete_at(0)
      end

      column_zip(columns, data)
    end

    def command(cmd, time = nil)
      time = Time.now.to_i unless time
      query(:command, "[#{time}] #{cmd}")
    end

    private

    def column_zip(columns, data)
      data.map do |d|
        Hash[columns.zip(d)]
      end
    end
  end

end
