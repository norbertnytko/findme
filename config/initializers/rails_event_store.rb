require 'aggregate_root'
require "arkency/command_bus"
require "arkency/command_bus/alias"

Rails.configuration.to_prepare do
  Rails.configuration.event_store = event_store = RailsEventStore::JSONClient.new

  event_store.subscribe(OnePagers::OnePagerProjection.new, to: [
    OnePagers::Events::OnePagerPublished,
    OnePagers::Events::OnePagerDrafted,
    OnePagers::Events::OnePagerAssignedName,
    OnePagers::Events::OnePagerAssignedSlug,
    OnePagers::Events::OnePagerSelectedTheme,
    OnePagers::Events::OnePagerLinkAdded,
    OnePagers::Events::OnePagerLinkRemoved
  ])

  event_store.subscribe(OnePagers::ThemeBroadcaster.new, to: [
    OnePagers::Events::OnePagerSelectedTheme
  ])

  Rails.configuration.command_bus = command_bus = CommandBus.new
  register = command_bus.method(:register)

  {
    OnePagers::Commands::SelectTheme => OnePagers::OnSelectTheme.new(event_store: event_store),
    OnePagers::Commands::AssignName => OnePagers::OnAssignName.new(event_store: event_store),
    OnePagers::Commands::AssignSlug => OnePagers::OnAssignSlug.new(event_store: event_store),
    OnePagers::Commands::Draft => OnePagers::OnDraft.new(event_store: event_store),

  }.map(&register)

end

AggregateRoot.configure do |config|
  config.default_event_store = RailsEventStore::JSONClient.new
end
