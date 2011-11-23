require 'livestatus/connection'
require 'livestatus/models'
require 'sinatra/base'
require 'yajl'

module Livestatus
  class API < Sinatra::Base
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
      method, query = headers.delete(:query).split

      halt 400, 'invalid method' unless ['GET', 'COMMAND'].include?(method)
      method = method.downcase.to_sym

      c = Livestatus::Connection.new(:uri => 'unix:///var/nagios/rw/live')

      case method
      when :get
        res = c.get(query, headers).map(&:data)
      when :command
        res = c.command(query)
      end

      Yajl::Encoder.encode(res)
    end
  end
end
