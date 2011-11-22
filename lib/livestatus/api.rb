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
        [k[18..-1].downcase.to_sym, v]
      end]
    end

    get '/' do
      headers = parse_headers(request.env)

      halt 400, 'no query specified' unless headers.include?(:query)
      method, model = headers.delete(:query).split

      halt 400, 'invalid method' unless ['GET', 'COMMAND'].include?(method)
      method = method.downcase.to_sym

      c = Livestatus::Connection.new(:uri => 'unix:///var/nagios/rw/live')
      Yajl::Encoder.encode(c.handler.send(method, model, headers))
    end
  end
end
