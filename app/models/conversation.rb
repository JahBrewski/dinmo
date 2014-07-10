class Conversation < ActiveRecord::Base
  belongs_to :pupil, class_name: "User"
  belongs_to :expert, class_name: "User"
  belongs_to :number
  attr_accessor :message
  
  def self.clean_conversations
    find_each do |conversation|
      if conversation.outdated?
        conversation.destroy
      end
    end
  end

  def outdated
    # Conversation is considered outdated if the last message was sent over an hour ago.
    ( Time.now - last_message_sent_at ) / 60 / 60 > 1
  end
end
