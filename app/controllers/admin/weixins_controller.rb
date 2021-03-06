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
    @rot = JSON.parse($redis.get("wxRot_list##{@wxuin}"))

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

    @group = group @wxuin
  end

  def groups
    @user = params[:user_name]
    @uin = params[:uin]
    @members = []
    @group = group(@uin)
    @group.each do |g|
      if g['UserName'] == @user
        @group_name = g['NickName']
        @group_id = g['UserName']
        @members = g['MemberList']
        break
      end
    end

    @settings = JSON.parse($redis.get("#{@uin}_tran") || ''.to_json)
    @settings = [] if @settings.blank?

  end

  def msg_tran
    param = {
      from: params[:from],
      from_name: params[:from_name],
      from_group_name: params[:from_group_name],
      from_group_id: params[:from_group_id],
      to: params[:to],
      to_name: params[:to_name],
    }

    f = true

    uin = params[:uin]

    settings = JSON.parse($redis.get("#{uin}_tran") || ''.to_json)
    settings = [] if settings.blank?
    settings.each_with_index do |s, index|
      if s['from'] == param[:from] && s['to'] == param[:to]
        settings[index] = param
        f = false
      end
    end
    settings << param if f

    $redis.set("#{uin}_tran", settings.to_json)
    render json: {}
  end

  def tran_remove
    param = {
      from: params[:from],
      to: params[:to]
    }
    uin = params[:uin]
    new_s = []
    settings = JSON.parse($redis.get("#{uin}_tran") || ''.to_json)
    settings.each_with_index do |s, index|
      if (s['from'] == param[:from] && s['to'] == param[:to])
        next
      end
      new_s << s
    end
    $redis.set("#{uin}_tran", new_s.to_json)
    render json: {}
  end


  private

    def group(uin)
       group = JSON.parse $redis.get("wxRot_##{uin}#groups")
    end
end
