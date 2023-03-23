class CreateSocialMediaSnippets < ActiveRecord::Migration[7.0]
  def change
    create_table :social_media_snippets do |t|
      t.string :social_media_type
      t.text :content
      t.references :link, null: false, foreign_key: true

      t.timestamps
    end
  end
end
