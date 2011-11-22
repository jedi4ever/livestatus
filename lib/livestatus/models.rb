require "active_support/core_ext"

module Livestatus
  mattr_accessor :models
  self.models = []

  class Base
    attr_reader :data

    def initialize(data)
      @data = data.symbolize_keys!
    end

    def method_missing(name, *args)
      data[name.to_sym]
    end

    class << self
      def find(options = {})
        Livestatus.get(table_name, options).map do |data|
          new(data)
        end
      end

      def table_name
        to_s.demodulize.tableize.downcase.pluralize
      end

      def boolean_attributes(*accessors)
        accessors.each do |m|
          define_method(m) do
            data[m] == 1
          end
        end
      end

      def time_attributes(*accessors)
        accessors.each do |m|
          define_method(m) do
            Time.at(data[m].to_i)
          end
        end
      end
    end
  end

  module ID
    def id
      Digest::SHA1.hexdigest(_id)[0..7]
    end
  end

  module State
    def state
      {
        0 => :ok,
        1 => :warning,
        2 => :critical,
        3 => :unknown,
      }[data[:state]]
    end

    def state_class
      {
        :ok => :green,
        :warning => :yellow,
        :critical => :red,
        :unknown => :orange,
        :pending => :gray,
      }[state]
    end

    def state_type
      {
        0 => :soft,
        1 => :hard,
      }[data[:state_type]]
    end
  end

  module CheckType
    def check_type
      {
        0 => :active,
        1 => :passive,
      }[data[:check_type]]
    end
  end
end

# load all models and register in Livestatus.models
Dir["#{File.dirname(__FILE__)}/models/*.rb"].map do |path|
  File.basename(path, '.rb')
end.each do |name|
  require "livestatus/models/#{name}"
  Livestatus.models << "Livestatus::#{name.pluralize.classify}".constantize
end
