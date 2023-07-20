module OnePagers
  THEMES = ["light", "dark", "cupcake", "bumblebee", "emerald", "corporate", "synthwave", "retro", "cyberpunk",
    "valentine", "halloween", "garden", "forest", "aqua", "lofi", "pastel", "fantasy", "wireframe", "black", "luxury",
    "dracula", "cmyk", "autumn", "business", "acid", "lemonade", "night", "coffee", "winter"]

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

  Link = Struct.new(:id, :one_pager_id, :name, :url, :position, keyword_init: true)

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

      reorder_links(link_id: link_id, new_position: 1)
    end

    def change_link_name(name: , link_id:)
      link = @links.find { |link| link.id == link_id }
      return if name == link.name

      apply Events::OnePagerLinkNameChanged.new(data: { id: @id, name: name, link_id: link_id})
    end

    def change_link_url(url:, link_id:)
      link = @links.find { |link| link.id == link_id }
      return if url == link.url

      apply Events::OnePagerLinkUrlChanged.new(data: { id: @id, url: url, link_id: link_id})
    end

    def remove_link(link_id:)
      apply Events::OnePagerLinkRemoved.new(data: { id: @id, link_id: link_id})

      refresh_links_positions
      apply Events::OnePagerLinksReordered.new(data: { id: @id, links: @links.map { |link| { link_id: link.id, position: link.position } } })
    end

    def reorder_links(link_id:, new_position:)
      link = @links.find { |link| link.id == link_id }
      return unless link

      @links.delete(link)
      @links.sort_by!(&:position).insert(new_position - 1, link)
      refresh_links_positions

      apply Events::OnePagerLinksReordered.new(data: { id: @id, links: @links.map { |link| { link_id: link.id, position: link.position } } })
    end

    private

    def refresh_links_positions
      @links.each_with_index do |link, index|
        link.position = index
      end
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

    on Events::OnePagerLinkNameChanged do |event|
      link_to_modify = @links.find { |link| link.id == event.data.fetch(:link_id) }

      link_to_modify.name = event.data.fetch(:name)
    end

    on Events::OnePagerLinkUrlChanged do |event|
      link_to_modify = @links.find { |link| link.id == event.data.fetch(:link_id) }

      link_to_modify.url = event.data.fetch(:url)
    end

    on Events::OnePagerLinkRemoved do |event|
      @links.delete_if { |link| link.id == event.data.fetch(:link_id) }
    end

    on Events::OnePagerLinksReordered do |event|
      links_data = event.data.fetch(:links)


      links_data.each do |link_data|
        link_id = link_data[:link_id]
        position = link_data[:position]
        link = @links.find { |link| link.id == link_id }
        link.position = position if link
      end
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
