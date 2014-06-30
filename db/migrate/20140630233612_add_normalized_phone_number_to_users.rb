class AddNormalizedPhoneNumberToUsers < ActiveRecord::Migration
  def change
    add_column :users, :mobile_number_normalized, :string
  end
end
