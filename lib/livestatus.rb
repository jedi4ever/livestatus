require "active_support/core_ext"

require "livestatus/version"
require "livestatus/connection"
require "livestatus/models"

module Livestatus
  mattr_accessor :connection
  self.connection = nil

  def self.get(model, options = {})
    raise RuntimeError, "no global connection found" unless self.connection
    self.connection.get(model, options)
  end

  def self.command(cmd, time = nil)
    raise RuntimeError, "no global connection found" unless self.connection
    self.connection.command(cmd, time)
  end
end
