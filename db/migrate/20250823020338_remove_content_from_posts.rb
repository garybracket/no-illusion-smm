class RemoveContentFromPosts < ActiveRecord::Migration[7.2]
  def change
    # PRIVACY FIRST: Remove content storage - content should never be persisted
    remove_column :posts, :content, :text

    # Add metadata fields for post tracking without storing actual content
    add_column :posts, :content_length, :integer
    add_column :posts, :content_hash, :string # For deduplication without storing content
    add_column :posts, :platform_post_ids, :json, default: {} # Store external platform post IDs
  end
end
