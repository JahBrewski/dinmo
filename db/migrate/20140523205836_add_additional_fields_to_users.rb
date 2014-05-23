class AddAdditionalFieldsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :first_name, :string
    add_column :users, :last_name, :string
    add_column :users, :username, :string
    add_column :users, :mobile_number, :string
    add_column :users, :expertise, :string
  end
end
