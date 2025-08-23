class CreatePlatformConnections < ActiveRecord::Migration[7.2]
  def change
    create_table :platform_connections do |t|
      t.references :user, null: false, foreign_key: true
      t.string :platform_name
      t.text :access_token
      t.text :refresh_token
      t.datetime :expires_at
      t.json :settings
      t.boolean :is_active

      t.timestamps
    end
  end
end
