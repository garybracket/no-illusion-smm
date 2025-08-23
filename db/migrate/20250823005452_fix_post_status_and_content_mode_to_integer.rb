class FixPostStatusAndContentModeToInteger < ActiveRecord::Migration[7.2]
  def up
    # First update existing data to proper integer enum values
    execute <<-SQL
      UPDATE posts SET 
        status = CASE 
          WHEN status = 'draft' THEN '0'
          WHEN status = 'scheduled' THEN '1'  
          WHEN status = 'published' THEN '2'
          WHEN status = 'failed' THEN '3'
          WHEN status = '2' THEN '2'  -- Handle existing integer strings
          ELSE '2'  -- Default to published (most existing posts)
        END
    SQL
    
    execute <<-SQL
      UPDATE posts SET 
        content_mode = CASE 
          WHEN content_mode = 'business' THEN '0'
          WHEN content_mode = 'influencer' THEN '1'
          WHEN content_mode = 'personal' THEN '2'
          ELSE '0'  -- Default to business
        END
    SQL
    
    # Change column types to integer using PostgreSQL USING clause
    execute "ALTER TABLE posts ALTER COLUMN status TYPE integer USING status::integer"
    execute "ALTER TABLE posts ALTER COLUMN status SET DEFAULT 0"
    execute "ALTER TABLE posts ALTER COLUMN status SET NOT NULL"
    
    execute "ALTER TABLE posts ALTER COLUMN content_mode TYPE integer USING content_mode::integer"  
    execute "ALTER TABLE posts ALTER COLUMN content_mode SET DEFAULT 0"
    execute "ALTER TABLE posts ALTER COLUMN content_mode SET NOT NULL"
  end
  
  def down
    # Reverse the changes
    change_column :posts, :status, :string
    change_column :posts, :content_mode, :string
    
    # Convert back to string values
    execute <<-SQL
      UPDATE posts SET 
        status = CASE 
          WHEN status = 0 THEN 'draft'
          WHEN status = 1 THEN 'scheduled'
          WHEN status = 2 THEN 'published'
          WHEN status = 3 THEN 'failed'
          ELSE 'draft'
        END
    SQL
    
    execute <<-SQL
      UPDATE posts SET 
        content_mode = CASE 
          WHEN content_mode = 0 THEN 'business'
          WHEN content_mode = 1 THEN 'influencer'
          WHEN content_mode = 2 THEN 'personal'
          ELSE 'business'
        END
    SQL
  end
end
