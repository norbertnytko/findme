module OnePagers
  class Repository
    def initialize(event_store = Rails.configuration.event_store)
      @repository = AggregateRoot::Repository.new(event_store)
    end

    def with_one_pager(one_pager_id, &block)
      stream_name = "OnePager$#{one_pager_id}"
      @repository.with_aggregate(OnePager.new(one_pager_id), stream_name, &block)
    end
  end
end
