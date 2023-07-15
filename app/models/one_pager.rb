class OnePager < ApplicationRecord
  self.table_name = "one_pager_read_models"
  has_many :links, foreign_key: 'one_pager_read_models_id', class_name: 'LinkReadModel', autosave: true
  
  def to_param
    slug
  end
end
