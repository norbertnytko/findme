require_relative "../infra/lib/infra"
require_relative "../contexts/configuration"
require_relative "../app/read_models/configuration"

class Configuration
  def call(event_store:, command_bus:)
    Contexts::Configuration.new.call(event_store: event_store, command_bus: command_bus)
    ReadModels::Configuration.new.call(event_store: event_store)
  end
end
