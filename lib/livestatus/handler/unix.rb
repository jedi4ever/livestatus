require 'livestatus/handler'
require 'socket'
require 'yajl'

module Livestatus

  class UnixHandler < BaseHandler
    def initialize(config)
      @socket = UNIXSocket.open(config[:uri].sub(/^unix:\/\//, ''))
    end

    def get(table_name, options = {})
      data = super

      if options.include?(:columns)
        columns = options[:columns].split(" ")
      else
        columns = data.delete_at(0)
      end

      column_zip(columns, data)
    end

    def query(method, query, headers = {})
      headers.merge!({
        :response_header => "fixed16",
        :output_format => "json",
        :keep_alive => "on",
      })

      headers = headers.map { |k,v| "#{k.to_s.camelize}: #{v}" }.join("\n")
      headers += "\n" unless headers.empty?

      @socket.write("#{method.to_s.upcase} #{query}\n#{headers}\n")

      res = @socket.read(16)
      status, length = res[0..2].to_i, res[4..14].chomp.to_i

      unless status == 200
        raise HandlerException, "livestatus query failed with status #{status}"
      end

      Yajl::Parser.new.parse(@socket.read(length))
    end

    private

    def column_zip(columns, data)
      data.map do |d|
        Hash[columns.zip(d)]
      end
    end
  end

end
