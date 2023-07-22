module OnePagers
  class OnDraft
    def initialize(event_store)
      @repository = OnePagers::Repository.new
    end

    def call(command)
      @repository.with_one_pager(command.aggregate_id) { |one_pager| one_pager.draft }
    end
  end

  class OnSelectTheme
    def initialize(event_store)
      @repository = OnePagers::Repository.new
    end

    def call(command)
      @repository.with_one_pager(command.aggregate_id) { |one_pager| one_pager.select_theme(theme: command.theme) }
    end
  end

  class OnAssignName
    def initialize(event_store)
      @repository = OnePagers::Repository.new
    end

    def call(command)
      @repository.with_one_pager(command.aggregate_id) { |one_pager| one_pager.assign_name(name: command.name) }
    end
  end

  class OnAssignSlug
    def initialize(event_store)
      @repository = OnePagers::Repository.new
    end

    def call(command)
      @repository.with_one_pager(command.aggregate_id) { |one_pager| one_pager.assign_slug(slug: command.slug) }
    end
  end
end
