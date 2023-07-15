class AddThemeToOnePagers < ActiveRecord::Migration[7.0]
  def change
    add_column :one_pager_read_models, :theme, :string
  end
end
