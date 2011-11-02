require 'patron'
require 'yajl'
require 'cgi'

module Livestatus

  class PatronHandler < BaseHandler
    attr_accessor :session

    def initialize(config)
      @session = Patron::Session.new
      @session.timeout = 10
      @session.headers["User-Agent"] = "livestatus/#{VERSION} ruby/#{RUBY_VERSION}"
      @session.insecure = config[:insecure]
      @session.auth_type = config[:auth_type].to_sym
      @session.username = config[:username]
      @session.password = config[:password]
      @uri = config[:uri]
    end

    def query(method, query, headers = {})
      headers = headers.map { |k,v| "#{k.to_s.capitalize}: #{v}" }.join("\n")
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
