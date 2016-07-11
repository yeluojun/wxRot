class Api::V1::AutoReplies < Api::V1::BasesController

  # TODO no finish
  def create
    @wxuin = params[:wxuin]
    auto_params = auto_params
    if auto_params[:id].blank?
      auto_params[:wxuin] = params[:wxuin]
      @auto_reply = AutoReply.create!(auto_params)
    else
      @auto_reply = AutoReply.find(auto_params[:id])
      @auto_reply.update!(auto_params)
    end
    render json: { code: 200, data: @auto_reply }
  end

  private

  def auto_params
    params.require(:auto_reply).permit(:id, :lag_string, :content, :friend_id)
  end

end