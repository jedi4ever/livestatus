require 'livestatus/handler'
require 'socket'
require 'yajl'

module Livestatus

  class UnixHandler
    def initialize(connection, config)
      @connection = connection
      @path = config[:uri].sub(/^unix:\/\//, '')
    end

    def get(model, options = {})
      options.merge!({
        :response_header => "fixed16",
        :output_format => "json",
        :keep_alive => "on",
      })

      send("GET #{model.table_name}\n#{build_headers(options)}")
      status, length = recv

      unless status == 200
        raise HandlerException, "livestatus query failed with status #{status}"
      end

      data = Yajl::Parser.parse(recv(length))

      column_zip(data, options).map do |d|
        model.new(d, @connection)
      end
    end

    def command(cmd, time = nil)
      time = Time.now.to_i unless time
      send("COMMAND [#{time}] #{cmd}\n")
      nil
    end

    private

    def socket
      @socket ||= socket!
      @socket = socket! if @socket.closed?
      @socket
    end

    def socket!
      UNIXSocket.open(@path)
    end

    def send(msg)
      socket.write(msg + "\n")
    end

    def recv(length = nil)
      if length.nil?
        # read response header
        res = socket.read(16)
        [res[0..2].to_i, res[4..14].chomp.to_i]
      else
        # read response body
        socket.read(length)
      end
    end

    def build_headers(options)
      options.map do |k, v|
        if v.is_a?(Array)
          v.map do |e|
            "#{k.to_s.camelize}: #{e}"
          end
        else
          "#{k.to_s.camelize}: #{v}"
        end
      end.flatten.join("\n").tap do |s|
        s += "\n" unless s.empty?
      end
    end

    def column_zip(data, options)
      if options.include?(:columns)
        columns = options[:columns].split(" ")
      else
        columns = data.delete_at(0)
      end

      data.map do |d|
        Hash[columns.zip(d)]
      end
    end
  end

end
