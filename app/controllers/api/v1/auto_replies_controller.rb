class Api::V1::AutoRepliesController < Api::V1::BasesController
  before_action :login_check

  def create
    begin
      @wxuin = params[:wxuin]
      auto_params = auto_params_permit
      return render json: { code: 400, msg: '请选择好友' }  if params[:auto_reply][:user_str].blank?
      auto_params[:friend_id] = params[:auto_reply][:user_str].split(' ')[0]
      return render json: { code: 404, msg: '好友不存在'} if !Friend.where(id: auto_params[:friend_id], wxuin: @wxuin).exists?
      if auto_params[:id].blank?
        auto_params[:wxuin] = params[:wxuin]
        return render json: { code: 400, msg: '已经存在相同的配置' } if AutoReply.where(auto_params).exists?
        @auto_reply = AutoReply.create!(auto_params)
      else
        @auto_reply = AutoReply.find(auto_params[:id])
        @auto_reply.update!(auto_params)
      end
      render json: { code: 200, data: @auto_reply }
    rescue => ex
      render json: { code: 500, msg: ex.message }
    end
  end

  def destroy
    @auto_reply = AutoReply.find(params[:id])
    @auto_reply.destroy!
    render json: { code: 200, msg: '删除成功' }
  end

  private

  def auto_params_permit
    params.require(:auto_reply).permit(:id, :flag_string, :content, :friend_id)
  end
end
