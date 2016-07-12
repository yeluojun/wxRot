class Admin::WeixinsController < Admin::BasesController
  before_action :login_check

  def index
    # 从缓存获取所有的机器人
    @rots = []
    rot_lists = $redis.keys 'wxRot_list#*'
    rot_lists.each do |list|
      @rots << { wxuin: list, data: JSON.parse($redis.get(list)) }
    end
  end

  # 配置机器人
  # 私聊的自动回复
  # 群聊的回复
  # 创建群组
  # 自动拉群
  # 私聊
  # TODO 关于群组的一概不管先　
  def edit
    @wxuin = params[:wxuin]
    @rot = Weixin.find_by('wxuin', @wxuin)
    @auto_replies = AutoReply.includes(:friend).where(wxuin: @wxuin)
    @auto_replies.each do |reply|
      reply.user_str = reply.friend.NickName
    end
  end
end
