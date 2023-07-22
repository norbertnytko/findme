module OnePagers
  module Commands
    Draft = Struct.new(:aggregate_id, keyword_init: true)
    AssignSlug = Struct.new(:aggregate_id, :slug, keyword_init: true)
    SelectTheme = Struct.new(:aggregate_id, :theme, keyword_init: true)
    AssignName = Struct.new(:aggregate_id, :name, keyword_init: true)
  end
end