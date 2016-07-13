class Admin::AutoReplyGlobalsController < Admin::BasesController
  before_action :set_wxuin
  def new
    @auto_reply_global = AutoReplyGlobal.new
    @auto_reply_global.flag = (params[:flag] || 0).to_i
  end

  def edit
    @auto_reply_global = AutoReplyGlobal.find(params[:id])
  end

  private

  def set_wxuin
    @wxuin = params[:wxuin]
  end
end
