class Conversation < ActiveRecord::Base
  default_scope { order(:created_at => :desc) }
  belongs_to :pupil, class_name: "User"
  belongs_to :expert, class_name: "User"
  belongs_to :number
  has_many :messages, dependent: :destroy
  attr_accessor :message
  
  def self.clean_conversations
    find_each do |conversation|
      unless conversation.expert && conversation.expert.static_number?
        if conversation.has_not_sent_message?
          conversation.destroy
        elsif conversation.outdated?
          conversation.destroy
        end
      end
    end
  end

  def rateable?
    status == 'rateable'
  end

  def awaiting_rating?
    status == 'awaiting_rating'
  end

  def has_sent_message?
    last_message_sent_at != nil
  end

  def has_not_sent_message?
    last_message_sent_at == nil
  end

  def outdated?
    # Conversation is considered outdated if the last message was sent over two hours ago.
    ( Time.now - last_message_sent_at ) / 60 / 60 > 1
  end

  def send_sms_message(from, to, body, from_user)
    # remove from/to params? are they necessary?
    body = "My Experts user #{from_user.username}: " + body
    Client.account.messages.create(
      :from => from,
      :to => to,
      :body => body)
    self.update_attribute("last_message_sent_at", Time.now)
  end

  def get_routing_number
    pupil = self.pupil
    expert = self.expert
    if pupil.conversations.empty? && expert.conversations.empty?
      # sample method?
      Number.order("RANDOM()").first.number
    else
     
      pupil_nums = pupil.conversations.collect { |c| c.routing_number }
      expert_nums = expert.conversations.collect { |c| c.routing_number }
      used_numbers = pupil_nums + expert_nums
      
      purchased_numbers = Number.pluck(:number)
      available_numbers = purchased_numbers - used_numbers
      if available_numbers.any?
        # choose a random available number
        available_numbers.sample
      else
        # purchase a new number
        numbers = Client.account.available_phone_numbers.get('US').local.list
        number = numbers[0].phone_number
        twilio_num = Client.account.incoming_phone_numbers.create(:phone_number => number)
        # change to env var
        twilio_num.update(:sms_application_sid => "APec7c548232e8c91f607986d9881f39b6")
        Number.create(:number => number)
        number
      end
    end
  end

  def is_response_message(body)
    body =~ /^\s*responded/i
  end

  def process_static_message(body, from_user)
    self.messages.create(:body => body, :sender_id => from_user.id)
    Pusher.trigger('messages', 'refresh', {:message => 'processed static message'})
  end

  def process_expert_message(body, from_user)
    if is_response_message(body)
      process_response_message(body, from_user)
    else
      send_sms_message(self.routing_number, self.pupil.mobile_number_normalized, body, from_user)
    end
  end

  def process_pupil_message(body, from_user)
    if self.awaiting_rating?
      process_rating_message(body, from_user)
    else
      send_sms_message(self.routing_number, self.expert.mobile_number_normalized, body, from_user)
    end
  end

  def process_response_message(body, from_user)
    self.update_attribute("status", "awaiting_rating")
    body = "Thanks for using My Experts! #{self.expert.username.capitalize} has ended this conversation. Pease rate your expert by entering a single digit from 1 to 5. Five being the highest rating and one being the lowest."
    send_sms_message(self.routing_number, self.pupil.mobile_number_normalized, body, from_user)
  end

  def process_rating_message(body, from_user)
    if body =~/^[1-5]$/
      rating = body.to_i
      Rating.create :rater_id => self.pupil.id, :rated_id => self.expert.id, :score => rating
      body = "Thanks for rating #{self.expert.username.capitalize}!"
      send_sms_message(self.routing_number, self.pupil.mobile_number_normalized, body, from_user)
      self.destroy
    else
      body = "Please enter a single digit from one to five."
      send_sms_message(self.routing_number, self.pupil.mobile_number_normalized, body, from_user)
    end
  end

end
