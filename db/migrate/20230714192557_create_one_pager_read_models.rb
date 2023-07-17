class CreateOnePagerReadModels < ActiveRecord::Migration[7.0]
  def change
    create_table :one_pager_read_models, id: :uuid do |t|
      t.string :slug
      t.string :name
      t.string :state
      t.datetime :published_at

      t.timestamps
    end
  end
end
