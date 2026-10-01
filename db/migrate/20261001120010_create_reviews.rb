class CreateReviews < ActiveRecord::Migration[8.0]
  def change
    create_table :reviews do |t|
      t.references :property, null: false, foreign_key: true
      t.references :visit, null: false, foreign_key: true, index: { unique: true }
      t.references :seeker, null: false, foreign_key: { to_table: :users }
      t.integer :rating, null: false
      t.text :comment, null: false

      t.timestamps
    end
    add_check_constraint :reviews, "rating BETWEEN 1 AND 5", name: "reviews_rating_between_1_and_5"
  end
end
