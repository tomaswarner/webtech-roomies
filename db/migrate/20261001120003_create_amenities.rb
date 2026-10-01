class CreateAmenities < ActiveRecord::Migration[8.0]
  def change
    create_table :amenities do |t|
      t.string :name, null: false

      t.timestamps
    end
    add_index :amenities, :name, unique: true
  end
end
