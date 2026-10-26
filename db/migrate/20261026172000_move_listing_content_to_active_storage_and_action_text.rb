# Listing photographs move to Active Storage (has_many_attached :photos) and the description to
# Action Text (has_rich_text :description), so the old URL table and the plain-text column go away.
class MoveListingContentToActiveStorageAndActionText < ActiveRecord::Migration[8.0]
  def up
    execute <<~SQL
      INSERT INTO action_text_rich_texts (name, body, record_type, record_id, created_at, updated_at)
      SELECT 'description', description, 'Listing', id, NOW(), NOW()
      FROM listings
      WHERE description IS NOT NULL AND description <> ''
    SQL

    remove_column :listings, :description
    drop_table :listing_photos
  end

  def down
    create_table :listing_photos do |t|
      t.references :listing, null: false, foreign_key: true
      t.string :image_url, null: false
      t.string :caption
      t.integer :position, null: false, default: 0
      t.timestamps
    end
    add_index :listing_photos, [ :listing_id, :position ]

    add_column :listings, :description, :text
    execute <<~SQL
      UPDATE listings SET description = action_text_rich_texts.body
      FROM action_text_rich_texts
      WHERE action_text_rich_texts.record_type = 'Listing'
        AND action_text_rich_texts.record_id = listings.id
        AND action_text_rich_texts.name = 'description'
    SQL
    execute "DELETE FROM action_text_rich_texts WHERE record_type = 'Listing' AND name = 'description'"
  end
end
