class AddIndexToLinksUrl < ActiveRecord::Migration[7.0]
  def up
    enable_extension("pg_trgm");
    add_index(:links, :url, using: 'gin', opclass: :gin_trgm_ops)
  end

  def down
    remove_index(:links, :url)
  end
end
