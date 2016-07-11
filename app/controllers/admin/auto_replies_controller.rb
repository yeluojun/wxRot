class Admin::AutoRepliesController < Admin::BasesController
  before_action :set_wxuin

  def new
   @auto_reply = AutoReply.new
  end



  def edit
    @auto_reply = AutoReply.find(params[:id])
  end

  private

  def set_wxuin
    @wxuin = params[:wxuin]
  end
end
