class Admin::AutoRepliesController < Admin::BasesController
  before_action :set_wxuin

  def new
   @auto_reply = AutoReply.new
  end

  def edit
    @auto_reply = AutoReply.includes(:friend).find(params[:id])
    @auto_reply.user_str = "#{@auto_reply.friend.id} #{@auto_reply.friend.NickName}"
  end

  private

  def set_wxuin
    @wxuin = params[:wxuin]
  end
end
