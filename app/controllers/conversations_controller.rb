class ConversationsController < ApplicationController
  def new
    @pupil = params[:pupil_id]
    @expert = params[:expert_id]
    @conversation = Conversation.new
  end

  def create
    @conversation = Conversation.new(conversation_params)
    @expert = User.find(@conversation.expert_id)
    @from = @conversation.pupil

    if @expert.static_number?
      @routing_number = @expert.static_number
    else
      @routing_number = @conversation.get_routing_number
    end

    if @conversation.save
      @conversation.update_attribute("routing_number", @routing_number)
      @expert_num = @expert.mobile_number_normalized
      if @expert.static_number?
        @conversation.process_static_message(params[:conversation][:message], @from)
      else
        @conversation.send_sms_message(@conversation.routing_number, @expert_num, params[:conversation][:message], @from)
      end
      redirect_to users_path
    else
      render action: "new"
    end
  end

  def process_sms
    @from = User.where(:mobile_number_normalized => params[:From])[0]
    @routing_num = params[:To]

    if User.where(:static_number => @routing_num).any?
      # message is for a user -- probably a business --with a static number
      @conversation = Conversation.where(:routing_number => @routing_num).where("pupil_id = ?", @from)
      @conversation.process_static_message(params[:Body], @from)
    else
      @conversation = Conversation.where(:routing_number => @routing_num).where("pupil_id = ? OR expert_id = ?", @from.id, @from.id)[0]
      if @from == @conversation.expert
        @conversation.process_expert_message(params[:Body], @from)
      else
        @conversation.process_pupil_message(params[:Body], @from)
      end
    end
    
    render :nothing => true
  end

  private

  def conversation_params
    params.require(:conversation).permit(:pupil_id, :expert_id)
  end

end
