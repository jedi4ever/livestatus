require "livestatus/handler/base"

Dir["#{File.dirname(__FILE__)}/handler/*.rb"].each do |path|
  require "livestatus/handler/#{File.basename(path, '.rb')}"
end
