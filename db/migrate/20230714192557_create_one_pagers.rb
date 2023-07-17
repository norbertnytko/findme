class CreateOnePagers < ActiveRecord::Migration[7.0]
  def change
    create_table :one_pagers, id: :uuid do |t|
      t.string :slug
      t.string :name
      t.string :state
      t.datetime :published_at

      t.timestamps
    end
  end
end
