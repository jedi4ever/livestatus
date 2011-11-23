require 'livestatus/handler'
require 'socket'
require 'yajl'

module Livestatus

  class UnixHandler
    def initialize(connection, config)
      @connection = connection
      @socket = UNIXSocket.open(config[:uri].sub(/^unix:\/\//, ''))
    end

    def get(model, options = {})
      options.merge!({
        :response_header => "fixed16",
        :output_format => "json",
        :keep_alive => "on",
      })

      headers = options.map do |k,v|
        if v.is_a?(Array)
          v.map do |e|
            "#{k.to_s.camelize}: #{e}"
          end
        else
          "#{k.to_s.camelize}: #{v}"
        end
      end.flatten.join("\n")

      headers += "\n" unless headers.empty?

      @socket.write("GET #{model.table_name}\n#{headers}\n")

      res = @socket.read(16)
      status, length = res[0..2].to_i, res[4..14].chomp.to_i

      unless status == 200
        raise HandlerException, "livestatus query failed with status #{status}"
      end

      data = Yajl::Parser.new.parse(@socket.read(length))

      if options.include?(:columns)
        columns = options[:columns].split(" ")
      else
        columns = data.delete_at(0)
      end

      column_zip(columns, data).map do |d|
        model.new(d, @connection)
      end
    end

    def command(cmd, time = nil)
      time = Time.now.to_i unless time
      @socket.write("COMMAND [#{time}] #{cmd}\n\n")
      nil
    end

    private

    def column_zip(columns, data)
      data.map do |d|
        Hash[columns.zip(d)]
      end
    end
  end

end
