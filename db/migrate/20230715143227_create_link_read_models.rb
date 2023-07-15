class CreateLinkReadModels < ActiveRecord::Migration[7.0]
  def change
    create_table :link_read_models, id: :uuid do |t|
      t.references :one_pager_read_models, null: false, foreign_key: true, type: :uuid
      t.string :name
      t.string :url

      t.timestamps
    end
  end
end
