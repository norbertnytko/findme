require 'aggregate_root'
require "arkency/command_bus"
require "arkency/command_bus/alias"

require_relative "../../lib/configuration"

Rails.configuration.to_prepare do
  Rails.configuration.event_store = event_store = RailsEventStore::JSONClient.new
  Rails.configuration.command_bus = command_bus = CommandBus.new

  Configuration.new.call(event_store: event_store, command_bus: command_bus)
end

AggregateRoot.configure do |config|
  config.default_event_store = RailsEventStore::JSONClient.new
end
