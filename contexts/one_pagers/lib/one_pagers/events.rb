module OnePagers
  module Events
    class OnePagerPublished < RailsEventStore::Event; end
    class OnePagerDrafted < RailsEventStore::Event; end
    class OnePagerAssignedName < RailsEventStore::Event; end
    class OnePagerAssignedSlug < RailsEventStore::Event; end
    class OnePagerSelectedTheme < RailsEventStore::Event; end
    class OnePagerLinkAdded < RailsEventStore::Event; end
    class OnePagerLinkRemoved < RailsEventStore::Event; end
    class OnePagerLinkNameChanged < RailsEventStore::Event; end
    class OnePagerLinkUrlChanged < RailsEventStore::Event; end
    class OnePagerLinksReordered < RailsEventStore::Event; end
  end
end
