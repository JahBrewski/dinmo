class ConversationsController < ApplicationController
  account_sid = ENV["TWILIO_SID"]
  auth_token = ENV["TWILIO_TOKEN"]
  sms_application_sid = ENV["TWILIO_SMS_APPLICATION_SID"]

  @@client = Twilio::REST::Client.new account_sid, auth_token

  def new
    @pupil = params[:pupil_id]
    @expert = params[:expert_id]
    @conversation = Conversation.new
  end

  def create
    @conversation = Conversation.new(conversation_params)
    @routing_number = get_routing_number(@conversation)
    if @conversation.save
      @conversation.update_attribute("routing_number", @routing_number)
      @expert_num = User.find(@conversation.expert_id).mobile_number_normalized
      send_sms_message(@conversation.routing_number, @expert_num, params[:conversation][:message], @conversation)
      redirect_to users_path
    else
      render action: "new"
    end
  end

  def process_sms
    @from = User.where(:mobile_number_normalized => params[:From])[0]
    @routing_num = params[:To]
    @conversation = Conversation.where(:routing_number => @routing_num).where("pupil_id = ? OR expert_id = ?", @from.id, @from.id)[0]
    
    if @from == @conversation.expert
      # send to pupil
      @body = get_pupil_message_body
      send_sms_message(@conversation.routing_number, @conversation.pupil.mobile_number_normalized, @body, @conversation)
    else
      # send to expert
      @body = params[:Body]
      send_sms_message(@conversation.routing_number, @conversation.expert.mobile_number_normalized, @body, @conversation)
    end
    render 'process_sms.xml.erb', :content_type => 'text/xml'
  end

  private
    def send_sms_message(from, to, body, conversation)
      @@client.account.messages.create(
        :from => from,
        :to => to,
        :body => body)
      conversation.update_attribute("last_message_sent_at", Time.now)
    end

    def conversation_params
      params.require(:conversation).permit(:pupil_id, :expert_id)
    end

    def get_pupil_message_body
      if params[:Body] =~ /end/i
        "Thanks for using My Experts! #{@conversation.expert.username.capitalize} has ended this conversation."
      else
        params[:Body]
      end
    end

    def get_routing_number(conversation)
      pupil = conversation.pupil
      expert = conversation.expert
      if pupil.conversations.empty? && expert.conversations.empty?
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
          numbers = @@client.account.available_phone_numbers.get('US').local.list
          number = numbers[0].phone_number
          twilio_num = @@client.account.incoming_phone_numbers.create(:phone_number => number)
          twilio_num.update(:sms_application_sid => "APec7c548232e8c91f607986d9881f39b6")
          Number.create(:number => number)
          number
        end
      end
    end
end
