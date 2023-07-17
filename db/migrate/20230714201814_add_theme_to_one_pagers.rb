class AddThemeToOnePagers < ActiveRecord::Migration[7.0]
  def change
    add_column :one_pagers, :theme, :string
  end
end
