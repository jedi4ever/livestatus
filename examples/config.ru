require 'livestatus/api'

Livestatus::API.config = {
  :uri => "unix:///var/nagios/rw/live"
}

$0 = "livestatusd (#{Livestatus::API.config[:uri]})"
run Livestatus::API
