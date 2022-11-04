class AddLinksPublishedAt < ActiveRecord::Migration[7.0]
  def change
    add_column :links, :published_at, :timestamp
  end
end
