class CreatePostVariants < ActiveRecord::Migration[7.2]
  def change
    create_table :post_variants do |t|
      t.references :post, null: false, foreign_key: true
      t.string :platform_key
      t.string :content_hash
      t.integer :content_length
      t.integer :ai_tokens_used
      t.datetime :generated_at

      t.timestamps
    end
  end
end
