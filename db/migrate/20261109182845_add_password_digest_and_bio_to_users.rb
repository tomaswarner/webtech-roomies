class AddPasswordDigestAndBioToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :password_digest, :string
    add_column :users, :bio, :text
  end
end
