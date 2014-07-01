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
    if @conversation.save
      @conversation.update_attribute("routing_number", "+17792038833")
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
    puts params[:From]
    puts params[:To]
    
    binding.pry
    @conversation = Conversation.where(:routing_number => params[:To]).where("pupil_id = ? OR expert_id = ?", @from.id, @from.id)[0]
    @message = params[:Body]
    if @from == @conversation.expert
      # send to pupil
      @to = @conversation.pupil.mobile_number_normalized
    else
      # send to expert
      @to = @conversation.expert.mobile_number_normalized
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
        # select random number from available numbers
      else
        pupil_nums = pupil.conversations.collect { |c| c.routing_num }
        expert_nums = expert.conversations.collect { |c| c.routing_num }

      end
    end
end
