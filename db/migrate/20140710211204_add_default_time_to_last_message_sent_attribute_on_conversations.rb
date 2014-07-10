class AddDefaultTimeToLastMessageSentAttributeOnConversations < ActiveRecord::Migration
  def change
    change_column_default :conversations, :last_message_sent_at, :null => false, :default => Time.now
  end
end
