class ConversationsController < ApplicationController
  def new
    @pupil = params[:pupil_id]
    @expert = params[:expert_id]
    @conversation = Conversation.new
  end

  def create
    @conversation = Conversation.new(conversation_params)
    @from = @conversation.pupil
    @routing_number = get_routing_number(@conversation)
    if @conversation.save
      @conversation.update_attribute("routing_number", @routing_number)
      @expert_num = User.find(@conversation.expert_id).mobile_number_normalized
      @conversation.send_sms_message(@conversation.routing_number, @expert_num, params[:conversation][:message], @from)
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
      @conversation.process_expert_message(params[:Body], @from)
    else
      @conversation.process_pupil_message(params[:Body], @from)
    end
    #render 'process_sms.xml.erb', :content_type => 'text/xml'
    render :nothing => true
  end

  private

    def conversation_params
      params.require(:conversation).permit(:pupil_id, :expert_id)
    end

    #def get_pupil_message_body
    #  if params[:Body] =~ /^\s*responded/i
    #    "Thanks for using My Experts! #{@conversation.expert.username.capitalize} has ended this conversation."
    #  else
    #    params[:Body]
    #  end
    #end
end
