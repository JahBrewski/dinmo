class ConversationsController < ApplicationController
  account_sid = 'AC2a8835d662eb2fa5b818eebcf9f11290'
  auth_token = '5d255dcb6c2ffe294de1b824fe5fec5f'

  @@client = Twilio::REST::Client.new account_sid, auth_token

  def new
    binding.pry
    @pupil = params[:pupil_id]
    @expert = params[:expert_id]
    @conversation = Conversation.new
  end

  def create
    @conversation = Conversation.new(conversation_params)
    if @conversation.save
      @pupil_num = User.find(@conversation.pupil_id).formatted_number
      @expert_num = User.find(@conversation.expert_id).formatted_number
      @@client.account.messages.create(
        :from => "+17792038833",
        :to => @expert_num,
        :body => params[:conversation][:message])
      redirect_to users_path
    else
      render action: "new"
    end
  end

  def process_sms
    @from = params[:From]
    @to = params[:To]
    
    
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
