#!/usr/bin/env ruby

require 'livestatus'

c = Livestatus::Connection.new("https://nagios.example.com/live")

c.handler.session.insecure = true
c.handler.session.auth_type = :basic
c.handler.session.username = 'admin'
c.handler.session.password = 'password'

c.command("DISABLE_NOTIFICATIONS")
puts c.get("status").inspect
