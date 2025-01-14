class CreatePlayers < ActiveRecord::Migration[8.0]
  def change
    create_table :players do |t|
      t.string :name, null: false
      t.integer :ranking, default: 0
      t.string :profile_picture_url, null: false
      t.string :preferred_cue

      t.timestamps
    end
  end
end
