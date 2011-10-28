require 'patron'
require 'yajl'
require 'cgi'

module Livestatus

  class HandlerException < StandardError; end

  class BaseHandler
    def get(table, headers = {})
      data = query(:get, table, headers)

      if headers.include?("Columns")
        columns = headers["Columns"].split(" ")
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

  class PatronHandler < BaseHandler
    attr_accessor :session

    def initialize(uri)
      @session = Patron::Session.new
      @session.timeout = 10
      @session.headers["User-Agent"] = "livestatus/#{VERSION} ruby/#{RUBY_VERSION}"
      @uri = uri
    end

    def query(method, query, headers = {})
      headers = headers.map { |k,v| "#{k}: #{v}" }.join("\n")
      headers += "\n" unless headers.empty?

      query = CGI::escape("#{method.to_s.upcase} #{query}\n#{headers}")
      result = session.get("#{@uri}?q=#{query}")

      unless result.status == 200
        raise HandlerException, "livestatus query failed with status #{result.status}"
      end

      parser = Yajl::Parser.new
      data = parser.parse(result.body)

      if data[0][0] > 0
        raise HandlerException, "livestatus returned error: #{data[0][1]}"
      end

      return data[1]
    end
  end
end
