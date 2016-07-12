class Api::V1::FriendsController < Api::V1::BasesController

  before_action :login_check
  # 获取好友
  def friends
    @keyword = params[:query] || ''
    @friends = Friend.select(:id, :UserName, :NickName).where(VerifyFlag: 0, wxuin: params[:wxuin]).where('NickName like?', "%#{@keyword}%").to_a
    tmp = Friend.new(id: 0, UserName: :all, NickName: '全部')
    @friends = [tmp] + @friends
    render json: { code: 200, data: @friends }
  end
end
