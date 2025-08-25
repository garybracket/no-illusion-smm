class RestoreDevisePasswordFields < ActiveRecord::Migration[7.2]
  def change
    # Add back Devise password fields that were removed for Auth0
    add_column :users, :encrypted_password, :string, null: false, default: "" unless column_exists?(:users, :encrypted_password)
    add_column :users, :reset_password_token, :string unless column_exists?(:users, :reset_password_token)
    add_column :users, :reset_password_sent_at, :datetime unless column_exists?(:users, :reset_password_sent_at)
    add_column :users, :remember_created_at, :datetime unless column_exists?(:users, :remember_created_at)
    
    # Add indexes if they don't exist
    add_index :users, :reset_password_token, unique: true unless index_exists?(:users, :reset_password_token)
  end
end
