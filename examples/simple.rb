#!/usr/bin/env ruby

require 'livestatus'

puts Livestatus::Host.find.first.inspect
