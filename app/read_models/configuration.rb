require_relative '../models/application_record'
require_relative 'one_pager'
require_relative 'link'

module ReadModels
  class Configuration
    def call(event_store:)
      event_store.subscribe(OnePagerProjection.new, to: [
        OnePagers::Events::OnePagerPublished,
        OnePagers::Events::OnePagerDrafted,
        OnePagers::Events::OnePagerAssignedName,
        OnePagers::Events::OnePagerAssignedSlug,
        OnePagers::Events::OnePagerSelectedTheme,
        OnePagers::Events::OnePagerLinkAdded,
        OnePagers::Events::OnePagerLinkRemoved,
        OnePagers::Events::OnePagerLinkUrlChanged,
        OnePagers::Events::OnePagerLinkNameChanged,
        OnePagers::Events::OnePagerLinksReordered
      ])

      event_store.subscribe(OnePager::ThemeBroadcaster.new, to: [
        OnePagers::Events::OnePagerSelectedTheme
      ])
    end
  end

  private

  class OnePagerProjection
    def call(event)
      one_pager_read_model = OnePager.find_or_initialize_by(id: event.data[:id])
      case event
      when OnePagers::Events::OnePagerPublished
        one_pager_read_model.published_at = event.data[:published_at]
        one_pager_read_model.state = :published
      when OnePagers::Events::OnePagerDrafted
        one_pager_read_model.published_at = nil
        one_pager_read_model.state = :drafted
      when OnePagers::Events::OnePagerAssignedName
        one_pager_read_model.name = event.data[:name]
      when OnePagers::Events::OnePagerAssignedSlug
        one_pager_read_model.slug = event.data[:slug]
      when OnePagers::Events::OnePagerSelectedTheme
        one_pager_read_model.theme = event.data[:theme]
      when OnePagers::Events::OnePagerLinkAdded
        one_pager_read_model.links.build(name: event.data[:name], url: event.data[:url], id: event.data[:link_id])
      when OnePagers::Events::OnePagerLinkRemoved
        one_pager_read_model.links.find_by(id: event.data[:link_id]).destroy
      when OnePagers::Events::OnePagerLinkUrlChanged
        one_pager_read_model.links.find_by(id: event.data[:link_id]).update_attribute(:url, event.data[:url])
      when OnePagers::Events::OnePagerLinkNameChanged
        one_pager_read_model.links.find_by(id: event.data[:link_id]).update_attribute(:name, event.data[:name])
      when OnePagers::Events::OnePagerLinksReordered
        event.data[:links].each do |link|
          one_pager_read_model.links.find_by(id: link[:link_id]).update_attribute(:position, link[:position])
        end
      end

      one_pager_read_model.save!
    end
  end
end
