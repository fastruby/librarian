class CreateShares < ActiveRecord::Migration[7.0]
  def change
    create_table :shares do |t|
      t.references :link, null: false, foreign_key: true
      t.string :shortened_url
      t.string :utm_source
      t.string :utm_medium
      t.string :utm_campaign
      t.string :utm_term
      t.string :utm_content
      t.string :utm_id
      t.string :shared_link_name

      t.timestamps
    end
  end
end
