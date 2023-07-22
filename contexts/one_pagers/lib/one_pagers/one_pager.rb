module OnePagers
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

      reorder_links(link_id: link_id, new_position: 1)
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
end
