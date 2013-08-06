class CreateVideos < ActiveRecord::Migration
  def change
    create_table :videos do |t|
      t.string :key
      t.string :title
      t.string :media_type
      t.integer :section
      t.references :server

      t.timestamps
    end
    add_index :videos, :key
    add_index :videos, :server_id
  end
end
