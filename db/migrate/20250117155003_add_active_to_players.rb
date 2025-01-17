class AddActiveToPlayers < ActiveRecord::Migration[8.0]
  def change
    add_column :players, :active, :boolean, default: true, null: false
  end
end
