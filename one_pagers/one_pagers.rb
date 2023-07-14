module OnePagers
  module Events
    class OnePagerPublished < RailsEventStore::Event; end
    class OnePagerDrafted < RailsEventStore::Event; end
  end

  class OnePagerReadModelProjection
    def call(event)
      one_pager_read_model = OnePagerReadModel.find_or_initialize_by(id: event.data[:id])
      case event
      when Events::OnePagerPublished
        one_pager_read_model.published_at = event.data[:published_at]
        one_pager_read_model.state = 'published'
      when Events::OnePagerDrafted
        one_pager_read_model.published_at = nil
        one_pager_read_model.state = 'drafted'
      end
      one_pager_read_model.save!
    end
  end

  class OnePager
    include AggregateRoot
    class AlreadyPublished < StandardError; end
  
    def initialize(id)
      @state = :draft
      @id = id
    end

    def draft
      apply Events::OnePagerDrafted.new(data: { id: @id, published_at: nil })
    end
  
    def publish
      raise AlreadyPublished if state == :published
      apply Events::OnePagerPublished.new(data: { id: @id, published_at: Time.now })
    end
  
    on Events::OnePagerPublished do |event|
      @state = :published
      @published_at = event.data.fetch(:published_at)
    end

    on Events::OnePagerDrafted do |event|
      @state = :drafted
      @published_at = event.data.fetch(:published_at)
    end
  
    private
  
    attr_reader :state
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
