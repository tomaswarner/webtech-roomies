class CreateNeighborhoods < ActiveRecord::Migration[8.0]
  def change
    create_table :neighborhoods do |t|
      t.string :name, null: false

      t.timestamps
    end
    add_index :neighborhoods, :name, unique: true
  end
end
