class AddBusinessFieldToUsers < ActiveRecord::Migration
  def change
    add_column :users, :business, :boolean, :default => false
    add_column :users, :static_number, :string
  end
end
