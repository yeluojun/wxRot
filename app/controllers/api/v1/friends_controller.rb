class Api::V1::FriendsController < Api::V1::BasesController

  # 获取好友
  def friends
    @keyword = params[:query] || ''
    @friends = Friend.select(:id, :UserName, :NickName).where(VerifyFlag: 0, wxuin: params[:wxuin]).where('NickName like?', "%#{@keyword}%")
    render json: { code: 200, data: @friends }
  end
end
