class CreateServers < ActiveRecord::Migration
  def change
    create_table :servers do |t|
      t.string :name
      t.string :host
      t.string :address
      t.integer :port

      t.timestamps
    end
  end
end
