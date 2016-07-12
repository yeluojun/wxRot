class Api::V1::AutoReplyGlobalsController < Api::V1::BasesController
  before_action :login_check

  def create
    auto_reply_g = global_auto_params_permit
    auto_reply_g[:wxuin] = params[:wxuin]
    if auto_reply_g[:id].blank?
      return render json: { code: 400, msg: '系统已经存在相同的配置' } if AutoReplyGlobal.where(auto_reply_g).exists?
      @auto_reply_g = AutoReplyGlobal.create!(auto_reply_g)
    else
      return render json: { code: 400, msg: '系统已经存在相同的配置' } if AutoReplyGlobal.where(auto_reply_g).where.not(id: auto_reply_g[:id]).exists?
      @auto_reply_g =  AutoReplyGlobal.find(auto_reply_g[:id])
      @auto_reply_g.update!(auto_reply_g)
    end
    render json: { code: 200, msg: '操作成功' }
  end

  def destroy
    @auto_reply_g = AutoReplyGlobal.find(params[:id])
    @auto_reply_g.destroy!
    render json: { code: 200, msg: '删除成功' }
  end

  private

  def global_auto_params_permit
    params.require(:auto_reply_global).permit(:id, :flag, :flag_string, :content)
  end

end
