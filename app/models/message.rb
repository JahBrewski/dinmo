class Message < ActiveRecord::Base
  default_scope { order(:created_at => :desc) }
  belongs_to :conversation

  def sender
    User.find(self.sender_id)
  end

  def self.clean_messages
    find_each do |message|
      if message.outdated?
        message.destroy
      end
    end
  end

  def outdated?
    ( Time.now - created_at ) / 120 / 60 > 1
  end
end
