class AddFieldsToConversations < ActiveRecord::Migration
  def change
    add_column :conversations, :expert_id, :integer
    add_column :conversations, :pupil_id, :integer
    add_column :conversations, :routing_number, :string
  end
end
