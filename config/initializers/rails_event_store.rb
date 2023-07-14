require 'aggregate_root'

Rails.configuration.to_prepare do
  Rails.configuration.event_store = event_store = RailsEventStore::JSONClient.new

  event_store.subscribe(OnePagers::OnePagerReadModelProjection.new, to: [
    OnePagers::Events::OnePagerPublished,
    OnePagers::Events::OnePagerDrafted
  ])
end

AggregateRoot.configure do |config|
  config.default_event_store = RailsEventStore::JSONClient.new
end
