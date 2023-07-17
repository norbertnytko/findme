require_relative 'one_pagers/lib/one_pagers'

module Contexts
  class Configuration
    def call(event_store:, command_bus:)
      OnePagers::Configuration.new.call(event_store: event_store, command_bus: command_bus)
    end
  end
end
