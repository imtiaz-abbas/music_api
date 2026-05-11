class CreateSongs < ActiveRecord::Migration[8.1]
  def change
    create_table :songs do |t|
      t.string :title
      t.integer :duration
      t.references :artist, null: false, foreign_key: true

      t.timestamps
    end
  end
end
