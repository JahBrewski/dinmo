class AddActiveBooleanToNumbers < ActiveRecord::Migration
  def change
    add_column :numbers, :active, :boolean, :default => false
  end
end
