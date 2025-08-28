class CreateBetaSignups < ActiveRecord::Migration[7.2]
  def change
    create_table :beta_signups do |t|
      t.string :email, null: false
      t.string :name
      t.string :company
      t.text :current_platforms
      t.text :challenges
      t.string :how_heard_about_us
      t.integer :status, default: 0
      t.datetime :signup_date, null: false

      t.timestamps
    end
    
    add_index :beta_signups, :email, unique: true
    add_index :beta_signups, :status
    add_index :beta_signups, :signup_date
  end
end
