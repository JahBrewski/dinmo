class ConversationsController < ApplicationController
  account_sid = 'AC2a8835d662eb2fa5b818eebcf9f11290'
  auth_token = '5d255dcb6c2ffe294de1b824fe5fec5f'

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
      @pupil_num = User.find(@conversation.pupil_id).mobile_number_normalized
      @expert_num = User.find(@conversation.expert_id).mobile_number_normalized
      @@client.account.messages.create(
        :from => @conversation.routing_number,
        :to => @expert_num,
        :body => params[:conversation][:message])
      redirect_to users_path
    else
      render action: "new"
    end
  end

  def process_sms
    @from = User.where(:mobile_number_normalized => params[:From])[0]
    @routing_num = params[:To]
    @conversation = Conversation.where(:routing_number => @routing_num).where("pupil_id = ? OR expert_id = ?", @from.id, @from.id)[0]
    
    @message = params[:Body]
    if @from == @conversation.expert
      # send to pupil
      @@client.account.messages.create(
        :from => @conversation.routing_number,
        :to => @conversation.pupil.mobile_number_normalized,
        :body => @message)
    else
      # send to expert
      @@client.account.messages.create(
        :from => @conversation.routing_number,
        :to => @conversation.expert.mobile_number_normalized,
        :body => @message)
    end
    
    render 'process_sms.xml.erb', :content_type => 'text/xml'
  end

  private
    def conversation_params
      params.require(:conversation).permit(:pupil_id, :expert_id)
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
          available_numbers.sample.number
        else
          # purchase a new number
          numbers = @@client.account.available_phone_numbers.get('US').local.list
          number = numbers[0].phone_number
          @@client.account.incoming_phone_numbers.create(:phone_number => number)
          Number.create(number: number)
          number
        end
      end
    end
end
