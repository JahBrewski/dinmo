class AddFieldsToNumbers < ActiveRecord::Migration
  def change
    add_column :numbers, :number, :string
  end
end
