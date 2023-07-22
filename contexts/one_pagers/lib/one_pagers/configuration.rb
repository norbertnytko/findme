module OnePagers
  class Configuration
    def call(event_store:, command_bus:)
      register = command_bus.method(:register)

      {
        OnePagers::Commands::SelectTheme => OnePagers::OnSelectTheme.new(event_store: event_store),
        OnePagers::Commands::AssignName => OnePagers::OnAssignName.new(event_store: event_store),
        OnePagers::Commands::AssignSlug => OnePagers::OnAssignSlug.new(event_store: event_store),
        OnePagers::Commands::Draft => OnePagers::OnDraft.new(event_store: event_store),
      }.map(&register)
    end
  end
end
