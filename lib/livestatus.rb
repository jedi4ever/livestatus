require "active_support/core_ext"

require "livestatus/version"
require "livestatus/connection"
require "livestatus/model"

module Livestatus
  mattr_accessor :config
  self.config = {}

  def self.connection
    @@connection ||= connection!
  end

  def self.connection!
    Livestatus::Connection.new(config)
  end

  def self.get(table_name, options = {})
    connection.get(table_name, options)
  end

  def self.command(cmd, time = nil)
    connection.command(cmd, time)
  end
end
