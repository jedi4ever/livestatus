#!/usr/bin/env ruby

require 'livestatus'
require 'pp'

c = Livestatus::Connection.new({ :uri => "unix:///var/nagios/rw/live"})

c.command("DISABLE_NOTIFICATIONS")

# This complains for missing table_name
# puts c.get("status").inspect

q_host=Livestatus::Host.new({})
hosts=c.get(q_host)

hosts.each do |host|
  pp host
end

q_service=Livestatus::Service.new({})
sercives=c.get(q_service)

services.each do |service|
  pp service
end

