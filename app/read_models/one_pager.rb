class OnePager < ApplicationRecord
  self.table_name = 'one_pagers'
  has_many :links, foreign_key: 'one_pagers_id', class_name: 'Link', autosave: true
  
  def to_param
    slug
  end

  class ThemeBroadcaster
    def call(event)
      ActionCable.server.broadcast("theme_change:#{event.data[:id]}", { theme: event.data[:theme]})
    end
  end
end

