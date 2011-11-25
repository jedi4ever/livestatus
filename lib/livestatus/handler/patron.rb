require 'livestatus/handler'
require 'patron'
require 'yajl'

module Livestatus

  class PatronHandler
    attr_accessor :session

    def initialize(connection, config)
      @connection = connection
      @session = Patron::Session.new
      @session.timeout = 10
      @session.headers["User-Agent"] = "livestatus/#{VERSION} ruby/#{RUBY_VERSION}"
      @session.insecure = config.fetch(:insecure, false)
      @session.auth_type = config.fetch(:auth_type, :basic).to_sym
      @session.username = config[:username]
      @session.password = config[:password]
      @uri = config[:uri]
    end

    def get(model, options = {})
      query(:get, model.table_name, options).map do |data|
        model.new(data, @connection)
      end
    end

    def command(cmd, time = nil)
      time = Time.now.to_i unless time
      query(:command, "[#{time}] #{cmd}")
      nil
    end

    def query(method, query, headers = {})
      headers = Hash[headers.merge({
        :query => "#{method.to_s.upcase} #{query}"
      }).map do |k, v|
        v = Yajl::Encoder.encode(v) if v.is_a?(Array)
        ["X-Livestatus-#{k.to_s.dasherize}", v]
      end]

      result = session.get(@uri, headers)

      unless result.status == 200
        raise HandlerException, "livestatus query failed with status #{result.status}"
      end

      Yajl::Parser.parse(result.body)
    end
  end

end
