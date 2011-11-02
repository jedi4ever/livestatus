require "livestatus/model/base"

Dir["#{File.dirname(__FILE__)}/model/*.rb"].each do |path|
  require "livestatus/model/#{File.basename(path, '.rb')}"
end
