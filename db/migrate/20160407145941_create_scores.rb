class CreateScores < ActiveRecord::Migration[5.0]
  def change
    create_table :scores do |t|
      t.integer :event_id
      t.integer :schedule_name
      t.integer :kind
      t.integer :th
      t.integer :team1_id
      t.integer :team2_id
      t.string :score_attribute
      t.string :score1
      t.string :score2
      t.text :note
      t.integer :user_id

      t.timestamps
    end
    add_index :scores, :event_id
    add_index :scores, :schedule_name
    add_index :scores, :kind
    add_index :scores, :th
    add_index :scores, :team1_id
    add_index :scores, :team2_id
    add_index :scores, :score1
    add_index :scores, :score2
    add_index :scores, :score_attribute
    add_index :scores, :user_id
  end
end