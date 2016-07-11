class Api::V1::AutoReplies < Api::V1::BasesController

  def create
    @wxuin = params[:wxuin]
  end

  private

  params.require(:auto_reply).permit(:id, :lag_string, :content, :friend_id)
end