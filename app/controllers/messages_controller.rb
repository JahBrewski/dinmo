class MessagesController < ApplicationController
  def index
    @conversations = []
    if current_user.static_number?
      @conversations = current_user.conversations_as_expert
    else
      []
    end
  end

  def new
    @conversation = Conversation.find(params[:id])
    @message = @conversation.messages.new
  end

  def create
    #@conversation = Conversation.find(params[:id])
    binding.pry
    @message = Message.new(message_params)
    if @message.save
      @conversation = @message.conversation
      @conversation.send_sms_message(@conversation.routing_number, @conversation.pupil.mobile_number_normalized, params[:message][:body], @conversation.expert)
      redirect_to messages_path
    else
      render action: "new"
    end
  end

  private

  def message_params
    params.require(:message).permit(:body, :conversation_id)
  end
end
