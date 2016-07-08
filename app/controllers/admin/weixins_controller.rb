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
  # 自动拉群
  #
  def edit
    # 私聊
  end
end
