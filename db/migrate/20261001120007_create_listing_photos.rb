class CreateListingPhotos < ActiveRecord::Migration[8.0]
  def change
    create_table :listing_photos do |t|
      t.references :listing, null: false, foreign_key: true
      t.string :image_url, null: false
      t.string :caption
      t.integer :position, null: false, default: 0

      t.timestamps
    end
    add_index :listing_photos, [ :listing_id, :position ]
  end
end
