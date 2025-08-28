class AddSubscriptionTierToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :subscription_tier, :string, default: 'free'
    add_index :users, :subscription_tier
  end
end
