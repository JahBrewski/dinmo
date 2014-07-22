class AddStatusToConversations < ActiveRecord::Migration
  def change
    add_column :conversations, :status, :string, :default => 'active'
  end
end
