class AddPlatformUserIdToPlatformConnections < ActiveRecord::Migration[7.2]
  def change
    add_column :platform_connections, :platform_user_id, :string
  end
end
