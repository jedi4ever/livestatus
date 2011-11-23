#!/usr/bin/env ruby

require 'livestatus'

c = Livestatus::Connection.new("unix:///var/nagios/rw/live")

c.command("DISABLE_NOTIFICATIONS")
puts c.get("status").inspect
