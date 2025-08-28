class CreateSubscriptionTiers < ActiveRecord::Migration[7.2]
  def change
    create_table :subscription_tiers do |t|
      t.string :name
      t.string :slug
      t.integer :price_cents
      t.string :billing_interval
      t.json :features
      t.json :limits
      t.boolean :is_active
      t.integer :sort_order
      t.text :description

      t.timestamps
    end
  end
end
