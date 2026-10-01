class CreateApplications < ActiveRecord::Migration[8.0]
  def change
    create_table :applications do |t|
      t.references :listing, null: false, foreign_key: true
      t.references :seeker, null: false, foreign_key: { to_table: :users }
      t.text :message, null: false
      t.date :move_in_date, null: false
      t.integer :stay_duration_months, null: false
      t.string :status, null: false, default: "pending"

      t.timestamps
    end
    add_index :applications, [ :listing_id, :seeker_id ], unique: true
    add_index :applications, :status
    # A listing can never end up with two accepted applicants.
    add_index :applications, :listing_id, unique: true, where: "status = 'accepted'",
              name: "index_applications_on_listing_id_one_accepted"
  end
end
