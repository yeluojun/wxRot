class WxHeartJob < ApplicationJob
  # TODO 先数据库实现,再缓存实现
  queue_as :wx_default

  # 心跳包任务
  def perform(*args)
    @wx =  WxApi::Wx.new
    err_time = 0
    params = args.first
    uin, synckey, syn_string  = params[:uin], params[:synckey], ''

    # 更新synkey
    synckey['List'].each { |list| syn_string += "#{list['Key']}_#{list['Val']}|" }
    syn_string = syn_string.chop

    begin
      wx_data = JSON.parse $redis.get("wxRot_list##{uin}")
      cookies = wx_data['cookies']
    rescue => ex
      # p 'db error is :', ex.message
      return
    end

    # 获取所有的联系人列表
    # Thread.new do
    #   data = JSON.parse @wx.get_wx_contact_member_list wx_data['pass_ticket'], wx_data['skey'], cookies
    #   # 更新联系人列表
    #   # $redis.set("wxRot_MemberList##{uin}", data['MemberList'].to_json)
    #   # $redis.expire("wxRot_MemberList##{uin}", 300)
    #   data['MemberList'].each do |ret|
    #     begin
    #       Friend.where(wxuin: uin).delete_all
    #       params = Friend.params ret
    #       params[:wxuin] = uin
    #       Friend.create!(params)
    #     rescue => ex
    #       p 'update member list failed:', ex.message
    #     end
    #   end
    # end

    # 开启心跳之旅
    loop do
      # p 'ping ping ping...'
      params = {
        _: Time.now.to_i + 1000,
        r: Time.now.to_i,
        deviceid: "e#{rand(999999999999999)}",
        sid: wx_data['wxsid'],
        skey: wx_data['skey'],
        synckey: syn_string,
        uin: uin
      }
      wx_data['skey'] = URI::encode(wx_data['skey'])
      wx_data['skey'][0] = '%40'
      begin
        data = @wx.synccheck params, cookies
        if data.include? '1100' #失败 or 退出登陆了
          $redis.del("wxRot_list##{uin}")  # 删除缓存
          break
        elsif data.include? "selector:\"0\""
          # do nothing
        else
          # 获取更新
          base = { BaseRequest: { Uin: wx_data['wxuin'],Sid: wx_data['wxsid'] , Skey: wx_data['skey'], DeviceID: "e#{rand(999999999999999)}"}, SyncKey: synckey , rr: Time.now.to_i }
          data = JSON.parse @wx.webwxsync wx_data, base, cookies

          # 更新 synckey
          synckey, syn_string = data['SyncKey'], ''
          data['SyncKey']['List'].each { |list| syn_string += "#{list['Key']}_#{list['Val']}|" }
          syn_string = syn_string.chop

          # 保存聊天记录
          # Thread.new do
          #   save_chat_history data['AddMsgList'], uin
          # end
          # 自动回复
          Thread.new do
            data['AddMsgList'].each do |msg|

              case msg['MsgType'].to_i
                when 37 # 添加好友申请
                  base = {
                    BaseRequest: { Uin: wx_data['wxuin'],Sid: wx_data['wxsid'] , Skey: wx_data['skey'], DeviceID: "e#{rand(999999999999999)}"},
                    Opcode: 3,
                    SceneList:[33],
                    SceneListCount:1,
                    VerifyContent: '',
                    VerifyUserList: [{
                      Value: msg['RecommendInfo']['UserName'],
                      VerifyUserTicket: msg['RecommendInfo']['Ticket']
                    }],
                    VerifyUserListSize: 1,
                    skey: wx_data['skey']
                  }
                  data = @wx.friend_request_accept(wx_data['pass_ticket'], base ,cookies)
                else
                  p '全局自动恢复'
                  auto_reply_global(msg, wx_data, cookies)
              end

            end
          end
        end
        err_time = 0
      rescue => ex
        err_time += 1
        if err_time >= 5
          # $redis.del("wxRot_list##{uin}")
          break
        end
      end
      $redis.expire("wxRot_list##{uin}", 300)
      $redis.expire("wxRot_##{uin}#friends", 300)
      $redis.expire("wxRot_##{uin}#groups", 300)
      sleep 1
    end
    # TODO 等待子线程完成后再结束父级进程
  end

  private

  # 保存聊天记录
  def save_chat_history(msg_array, uin)
    msg_array.each do |msg|
      begin
        @history = ::ChatHistory.create!({ MsgId: msg['MsgId'], FromUserName: msg['FromUserName'], ToUserName: msg['ToUserName'],MsgType: msg['MsgType'], Content: msg['Content'], wxuin: uin })
      rescue => ex
        p "#{uin}聊天记录保存失败:", ex.message
      end
    end
  end

  # 处理全局自动回复(只对应文字回复)
  # FIXME has many bug
  # FIXME have to 重构
  def auto_reply_global(msg, wx_data, cookies)
    # TODO 防止撤回
    from_user = msg['FromUserName']
    to_user = msg['ToUserName'] # 这个才是我
    content = msg['Content'].gsub('br/', '/n').strip
    msg_id =  "#{Time.now.to_i}#{rand.to_s[0,5]}".gsub('.','')
    base = {
      BaseRequest: { Uin: wx_data['wxuin'],Sid: wx_data['wxsid'] , Skey: wx_data['skey'], DeviceID: "e#{rand(999999999999999)}"},
      Msg: { ClientMsgId: msg_id, FromUserName: to_user, LocalID: msg_id, ToUserName: from_user, Type: 1 },
      Scene: 0
    }
    # p '原信息是?', msg
    # p '来自谁?', from_user
    # p '发给谁?', to_user
    # p '内容?', content
    # p 'msg id ?', msg_id

    if to_user == 'filehelper'
      if content == 'stop' # 停止机器人
　　     $redis.set("#{wx_data['wxuin']}-control", 'stop')
      elsif content == 'start' # 开启机器人
　　　　　$redis.set("#{wx_data['wxuin']}-control", 'start')
      end
    elsif from_user[0,2] != '@@' && from_user != wx_data['UserName'] && $redis.get("#{wx_data['wxuin']}-control") != 'stop' # 私聊
      # p '私聊回复'
      # TODO FIND THE REAL PEOPLE
      friends = JSON.parse($redis.get("wxRot_##{wx_data['wxuin']}#friends"))
      friend = get_friend_name(wx_data['wxuin'], from_user)
      auto_reply(0,base,wx_data,cookies, content, from_user) if friend.present? && friend['VerifyFlag'] == 0 # 判断这个是人
    elsif from_user[0,2] == '@@' && $redis.get("#{wx_data['wxuin']}-control") != 'stop' # 群聊
      # TODO 判断缓存中是否存在该群组，如果不存在 获取并保存
      # TODO 群显示名称？ ‘昵称’？ ‘微信名’
      user = content.split(':')[0]
      from_display_name = ''
      group = nil
      groups = begin
        JSON.parse $redis.get("wxRot_##{wx_data['wxuin']}#groups")
      rescue
        []
      end
      if groups.blank?
        # TODO 重新获取群组
        get_group_msg wx_data, from_user, cookies
      else
        groups.each do |g|
         if g['UserName'] == from_user
            group = g
            break
          end
        end
      end
      group = get_group_msg(wx_data, from_user, cookies) if group.blank?
      group['MemberList'].each do |m|
        if m['UserName'] == user
          from_display_name = m['DisplayName']
          if from_display_name.blank?
            friend = get_friend_name(wx_data['wxuin'], user)
            if friend.present?
              from_display_name = friend['NickName']
            else
              from_display_name = m['NickName']
            end
          end
          # from_display_name = m['NickName'] if display_name.blank?
          break
        end
      end
      #查找出我 @我 TODO 暂时关掉
      # group['MemberList'].each do |m|
      #   if m['UserName'] == wx_data['UserName']
      #     display_name = m['DisplayName']
      #     display_name = m['NickName'] if display_name.blank?
      #     p 'what is my display_name?', display_name, content
      #     if content.include?("@#{display_name}") # 包含@我的信息
      #       # from who
      #       # TODO 自动回复
      #       p '群组自动回复'
      #       auto_reply(1, base, wx_data, cookies, content, from_user, display_name = "@#{from_display_name} ")
      #     end
      #     break
      #   end
      # end
      tran(wx_data, user, content, base, cookies, msg[:MsgType].to_i)
    end
  end

  def tran(wx_data, user, content, base, cookies, msg_type)
    settings = JSON.parse($redis.get("#{wx_data['wxuin']}_tran") || ''.to_json)
    settings = [] if settings.blank?
    settings.each do |s|
      if user == s['from']
        content = content.split(':')[1].gsub('</n>', "\n")
        content = content.split(':')[1].gsub('<br/>', "\n")
        if msg_type == 1
          base[:Msg][:Content] = "#{s['from_name']}说：#{content}"
        else
          base[:Msg][:Content] = "#{s['from_name']}发了非文字信息，赶快去查看！"
        end
        base[:Msg][:ToUserName] = s['to']
        @wx.send_msg(wx_data['pass_ticket'], base, cookies)
      end
    end
  end

  def get_friend_name(uin, username)
    friends = JSON.parse($redis.get("wxRot_##{uin}#friends"))
    friends.each do |friend|
      if friend['UserName'] == username
        return friend
      end
    end
    nil
  end

  # 处理个人的自动回复
  def auto_reply(flag, base, wx_data, cookies, content, from_user, display_name = nil)

    auto_reply_g = AutoReplyGlobal.where("(flag_string = ? || flag_string = ?) and wxuin = ? and flag = #{flag}", content, '*', wx_data['wxuin']).first
    if !auto_reply_g.blank?
      if auto_reply_g.content != 'tl'
        auto_reply_g.content = display_name + auto_reply_g.content unless display_name.blank?
        base[:Msg][:Content] = auto_reply_g.content
        @wx.send_msg(wx_data['pass_ticket'], base, cookies)
      else
        p '图灵机器人回复:'
        @wx.char_with_tuliung wx_data['pass_ticket'], base, cookies, from_user, content, display_name
      end
      # auto_reply_g = AutoReplyGlobal.where("(flag_string = ?) and wxuin = ? and flag = #{flag}", '*', wx_data['wxuin']).first
      # unless auto_reply_g.blank?
      #   if auto_reply_g.content != 'tl' # 全局非图灵机器人
      #     base[:Msg][:Content] = auto_reply_g.content
      #     @wx.send_msg(wx_data['pass_ticket'], base, cookies)
      #   else
      #     @wx.char_with_tuliung wx_data['pass_ticket'], base, cookies, from_user, content # 全局图灵机器人
      #   end
      # end
    end
  end

  # 获取群组信息
  def get_group_msg(wx, username, cookies)
    # 获取以前的群组信息
    groups = $redis.get "wxRot_##{wx[:wxuin]}#groups"
    unless  groups.blank?
      groups = JSON.parse groups
    end
    group_list = []
    group_list.push({ EncryChatRoomId: '', UserName: username })
    base = {
      BaseRequest: { Uin: wx['wxuin'],Sid: wx['wxsid'] , Skey: wx['skey'], DeviceID: "e#{rand(999999999999999)}"},
      Count: group_list.length,
      List: group_list
    }
    data = JSON.parse @wx.get_wx_batchget_contact wx['pass_ticket'], base , cookies

    if groups.blank?
      $redis.set("wxRot_##{wx[:wxuin]}#groups", data['ContactList'].to_json)
    else
      groups.push(data['ContactList'][0])
      $redis.set("wxRot_##{wx[:wxuin]}#groups", groups.to_json)
      p '重新加入了组, 新的组的长度是：'
      p JSON.parse($redis.get("wxRot_##{wx[:wxuin]}#groups")).length
    end
    $redis.expire("wxRot_##{wx[:wxuin]}#groups", 300)
    data['ContactList'][0]
  end
end
