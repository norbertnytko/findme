require_relative "../contexts/configuration"

class Configuration
  def call(event_store:, command_bus:)
    Contexts::Configuration.new.call(event_store: event_store, command_bus: command_bus)
  end
end
