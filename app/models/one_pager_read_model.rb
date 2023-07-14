class OnePagerReadModel < ApplicationRecord
  def to_param
    slug
  end
end
