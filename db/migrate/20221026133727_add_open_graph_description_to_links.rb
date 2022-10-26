class AddOpenGraphDescriptionToLinks < ActiveRecord::Migration[7.0]
  def change
    add_column :links, :open_graph_description, :text, default: ""
  end
end
