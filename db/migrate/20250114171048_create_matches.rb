class CreateMatches < ActiveRecord::Migration[8.0]
  def change
    create_table :matches do |t|
      t.integer :player1_id, null: false
      t.integer :player2_id, null: false
      t.datetime :start_time, null: false
      t.datetime :end_time
      t.integer :winner_id
      t.integer :table_number

      t.timestamps
    end
    add_foreign_key :matches, :players, column: :player1_id
    add_foreign_key :matches, :players, column: :player2_id
    add_foreign_key :matches, :players, column: :winner_id, optional: true
  end
end
