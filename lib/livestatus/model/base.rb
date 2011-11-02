module Livestatus
  class Base
    def initialize(data)
      @data = data.symbolize_keys!
    end

    def self.find(options = {})
      Livestatus.get(table_name, options).map do |data|
        self.new(data)
      end
    end

    def self.table_name
      self.to_s.demodulize.tableize.downcase.pluralize
    end

    def method_missing(name, *args)
      @data[name.to_sym]
    end
  end
end
