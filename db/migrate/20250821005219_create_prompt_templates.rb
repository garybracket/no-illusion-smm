class CreatePromptTemplates < ActiveRecord::Migration[7.2]
  def change
    create_table :prompt_templates do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name
      t.text :prompt_text
      t.string :content_mode
      t.boolean :is_system
      t.boolean :is_public

      t.timestamps
    end
  end
end
