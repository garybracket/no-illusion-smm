class AddIsActiveToPromptTemplates < ActiveRecord::Migration[7.2]
  def change
    add_column :prompt_templates, :is_active, :boolean, default: false
    add_index :prompt_templates, [ :user_id, :content_mode, :is_active ]
  end
end
