class AddAuthColumnsToUser < ActiveRecord::Migration[7.0]
  def change
    change_table :users do |t|
      t.string :provider
      t.string :uid, unique: true
      t.string :name
    end
  end
end
