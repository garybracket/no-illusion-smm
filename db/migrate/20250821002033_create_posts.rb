class CreatePosts < ActiveRecord::Migration[7.2]
  def change
    create_table :posts do |t|
      t.references :user, null: false, foreign_key: true
      t.text :content
      t.text :platforms
      t.string :status
      t.string :content_mode
      t.boolean :ai_generated
      t.datetime :scheduled_for

      t.timestamps
    end
  end
end
