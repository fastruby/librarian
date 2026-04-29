class CreatePersonalAccessTokens < ActiveRecord::Migration[7.0]
  def change
    create_table :personal_access_tokens do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name, null: false
      t.string :token_digest, null: false
      t.datetime :last_used_at
      t.datetime :expires_at

      t.timestamps
    end

    add_index :personal_access_tokens, :token_digest, unique: true
  end
end
