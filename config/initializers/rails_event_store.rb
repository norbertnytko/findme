require 'aggregate_root'

Rails.configuration.to_prepare do
  Rails.configuration.event_store = RailsEventStore::JSONClient.new
end

AggregateRoot.configure do |config|
  config.default_event_store = RailsEventStore::JSONClient.new
end
