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

    # 对人的自动回复
    @auto_replies = AutoReply.includes(:friend).where(wxuin: @wxuin)
    @auto_replies.each do |reply|
      reply.user_str = reply.friend.NickName
    end

    # 全局自动回复/@自动回复
    @auto_reply_g_normal = []
    @auto_reply_g_at = []
    @auto_reply_globals = AutoReplyGlobal.where(wxuin: @wxuin)
    @auto_reply_globals.each do |reply|
      if reply.flag == 0
        @auto_reply_g_normal.push reply
      elsif reply.flag == 1
        @auto_reply_g_at.push reply
      end
    end
  end
end
