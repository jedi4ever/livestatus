require "active_support/core_ext"

require "livestatus/version"
require "livestatus/connection"
require "livestatus/models"

module Livestatus
  mattr_accessor :connection
  self.connection = nil
end
