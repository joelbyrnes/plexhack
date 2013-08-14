class CreateVideoNotes < ActiveRecord::Migration
  def change
    create_table :video_notes do |t|
      t.references :video
      t.references :user
      t.integer :rating
      t.text :comment

      t.timestamps
    end
    add_index :video_notes, :video_id
    add_index :video_notes, :user_id
  end
end
