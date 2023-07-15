module OnePagers
  THEMES = ["light", "dark", "cupcake", "bumblebee", "emerald", "corporate", "synthwave", "retro", "cyberpunk",
    "valentine", "halloween", "garden", "forest", "aqua", "lofi", "pastel", "fantasy", "wireframe", "black", "luxury",
    "dracula", "cmyk", "autumn", "business", "acid", "lemonade", "night", "coffee", "winter"]

  module Events
    class OnePagerPublished < RailsEventStore::Event; end
    class OnePagerDrafted < RailsEventStore::Event; end
    class OnePagerAssignedName < RailsEventStore::Event; end
    class OnePagerAssignedSlug < RailsEventStore::Event; end
    class OnePagerSelectedTheme < RailsEventStore::Event; end
    class OnePagerLinkAdded < RailsEventStore::Event; end
    class OnePagerLinkRemoved < RailsEventStore::Event; end
  end

  module Commands
    Draft = Struct.new(:aggregate_id, keyword_init: true)
    AssignSlug = Struct.new(:aggregate_id, :slug, keyword_init: true)
    SelectTheme = Struct.new(:aggregate_id, :theme, keyword_init: true)
    AssignName = Struct.new(:aggregate_id, :name, keyword_init: true)
  end

  class OnDraft
    def initialize(event_store)
      @repository = OnePagers::OnePagerRepository.new
    end

    def call(command)
      @repository.with_one_pager(command.aggregate_id) { |one_pager| one_pager.draft }
    end
  end

  class OnSelectTheme
    def initialize(event_store)
      @repository = OnePagers::OnePagerRepository.new
    end

    def call(command)
      @repository.with_one_pager(command.aggregate_id) { |one_pager| one_pager.select_theme(theme: command.theme) }
    end
  end

  class OnAssignName
    def initialize(event_store)
      @repository = OnePagers::OnePagerRepository.new
    end

    def call(command)
      @repository.with_one_pager(command.aggregate_id) { |one_pager| one_pager.assign_name(name: command.name) }
    end
  end

  class OnAssignSlug
    def initialize(event_store)
      @repository = OnePagers::OnePagerRepository.new
    end

    def call(command)
      @repository.with_one_pager(command.aggregate_id) { |one_pager| one_pager.assign_slug(slug: command.slug) }
    end
  end

  class ThemeBroadcaster
    def call(event)
      ActionCable.server.broadcast("theme_change:#{event.data[:id]}", { theme: event.data[:theme]})
    end
  end

  class OnePagerProjection
    def call(event)
      one_pager_read_model = ::OnePager.find_or_initialize_by(id: event.data[:id])
      case event
      when Events::OnePagerPublished
        one_pager_read_model.published_at = event.data[:published_at]
        one_pager_read_model.state = :published
      when Events::OnePagerDrafted
        one_pager_read_model.published_at = nil
        one_pager_read_model.state = :drafted
      when Events::OnePagerAssignedName
        one_pager_read_model.name = event.data[:name]
      when Events::OnePagerAssignedSlug
        one_pager_read_model.slug = event.data[:slug]
      when Events::OnePagerSelectedTheme
        one_pager_read_model.theme = event.data[:theme]
      when Events::OnePagerLinkAdded
        one_pager_read_model.links.build(name: event.data[:name], url: event.data[:url], id: event.data[:link_id])
      when Events::OnePagerLinkRemoved
        one_pager_read_model.links.find_by(id: event.data[:link_id]).destroy
      end

      one_pager_read_model.save!
    end
  end

  Link = Struct.new(:id, :one_pager_id, :name, :url, keyword_init: true)

  class OnePager
    include AggregateRoot
    class AlreadyPublished < StandardError; end
  
    def initialize(id)
      @state = :draft
      @id = id
      @links = []
    end

    def draft
      apply Events::OnePagerDrafted.new(data: { id: @id, published_at: nil })
    end
  
    def publish
      raise AlreadyPublished if @state == :published
      apply Events::OnePagerPublished.new(data: { id: @id, published_at: Time.now })
    end

    def assign_name(name:)
      apply Events::OnePagerAssignedName.new(data: { id: @id, name: name })
    end

    def assign_slug(slug:)
      apply Events::OnePagerAssignedSlug.new(data: { id: @id, slug: slug })
    end

    def select_theme(theme:)
      apply Events::OnePagerSelectedTheme.new(data: { id: @id, theme: theme })
    end

    def add_link(name:, url:, link_id:)
      apply Events::OnePagerLinkAdded.new(data: { id: @id, name: name, url: url, link_id: link_id})
    end

    def remove_link(link_id:)
      apply Events::OnePagerLinkRemoved.new(data: { id: @id, link_id: link_id})
    end
  
    on Events::OnePagerPublished do |event|
      @state = :published
      @published_at = event.data.fetch(:published_at)
    end

    on Events::OnePagerDrafted do |event|
      @state = :drafted
      @published_at = event.data.fetch(:published_at)
    end

    on Events::OnePagerAssignedName do |event|
      @name = event.data.fetch(:name)
    end

    on Events::OnePagerAssignedSlug do |event|
      @slug = event.data.fetch(:slug)
    end

    on Events::OnePagerSelectedTheme do |event|
      @theme = event.data.fetch(:theme)
    end

    on Events::OnePagerLinkAdded do |event|
      @links << Link.new(
        id: event.data.fetch(:link_id),
        one_pager_id: @id,
        name: event.data.fetch(:name),
        url: event.data.fetch(:url)
      )
    end

    on Events::OnePagerLinkRemoved do |event|
      @links.delete_if { |link| link.id == event.data.fetch(:link_id) }
    end
  end

  class OnePagerRepository
    def initialize(event_store = Rails.configuration.event_store)
      @repository = AggregateRoot::Repository.new(event_store)
    end
  
    def with_one_pager(one_pager_id, &block)
      stream_name = "OnePager$#{one_pager_id}"
      repository.with_aggregate(OnePager.new(one_pager_id), stream_name, &block)
    end
  
    private
    attr_reader :repository
  end
end
