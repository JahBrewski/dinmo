class AddDefaultValueToUsersStatus < ActiveRecord::Migration
  def change
    change_column_default :users, :status, "inactive"
  end
end
