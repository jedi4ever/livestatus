require "active_support/core_ext"
require 'livestatus/connection'
require 'livestatus/models'
require 'sinatra/base'
require 'yajl'

module Livestatus
  class API < Sinatra::Base
    cattr_accessor :config

    def parse_headers(env)
      Hash[env.select do |k, v|
        k =~ /^HTTP_X_LIVESTATUS_/
      end.map do |k, v|
        v = Yajl::Parser.parse(v) if v =~ /^\[/
        [k[18..-1].downcase.to_sym, v]
      end]
    end

    get '/' do
      headers = parse_headers(request.env)

      halt 400, 'no query specified' unless headers.include?(:query)
      method, query = headers.delete(:query).split(' ', 2)

      halt 400, 'invalid method' unless ['GET', 'COMMAND'].include?(method)
      method = method.downcase.to_sym

      c = Livestatus::Connection.new(self.config)

      case method
      when :get
        res = c.get(Livestatus.models[query], headers).map(&:data)
      when :command
        query =~ /\[([0-9]+)\] (.*)/
        time, command = $1.to_i, $2
        res = c.command(command, time)
      end

      Yajl::Encoder.encode(res)
    end
  end
end
