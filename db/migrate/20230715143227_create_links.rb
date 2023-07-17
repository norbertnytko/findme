class CreateLinks < ActiveRecord::Migration[7.0]
  def change
    create_table :links, id: :uuid do |t|
      t.references :one_pagers, null: false, foreign_key: true, type: :uuid
      t.string :name
      t.string :url

      t.timestamps
    end
  end
end
