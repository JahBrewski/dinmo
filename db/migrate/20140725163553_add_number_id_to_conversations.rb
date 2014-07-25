class AddNumberIdToConversations < ActiveRecord::Migration
  def change
    add_column :conversations, :number_id, :integer
  end
end
