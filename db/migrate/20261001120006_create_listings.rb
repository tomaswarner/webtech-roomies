class CreateListings < ActiveRecord::Migration[8.0]
  def change
    create_table :listings do |t|
      t.references :property, null: false, foreign_key: true
      t.string :title, null: false
      t.string :status, null: false, default: "draft"
      t.decimal :monthly_rent, precision: 10, scale: 2, null: false
      t.decimal :deposit, precision: 10, scale: 2, null: false, default: 0
      t.date :available_on, null: false
      t.integer :minimum_stay_months, null: false, default: 1
      t.boolean :furnished, null: false, default: false
      t.boolean :private_bathroom, null: false, default: false
      t.text :description

      t.timestamps
    end
    add_index :listings, :status
    add_index :listings, :available_on
  end
end
