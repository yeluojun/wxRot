class WxHeartJob < ApplicationJob
  # TODO 先数据库实现,再缓存实现
  queue_as :default

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
      p 'db error is :', ex.message
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
      p 'ping ping ping...'
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
          Thread.new do
            save_chat_history data['AddMsgList'], uin
          end

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
                  auto_reply_global(msg, wx_data, cookies) unless auto_reply(msg, wx_data, cookies)
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
    if from_user[0,2] != '@@' && from_user != wx_data['UserName'] # 私聊
      auto_reply_g = AutoReplyGlobal.where('(flag_string = ?) and wxuin = ?', content, wx_data['wxuin']).first
      if !auto_reply_g.blank?
        if auto_reply_g.content != 'tl'
          base[:Msg][:Content] = auto_reply_g.content
          @wx.send_msg(wx_data['pass_ticket'], base, cookies)
        else
          @wx.char_with_tuliung wx_data['pass_ticket'], base, cookies, from_user, content
        end
      else
        auto_reply_g = AutoReplyGlobal.where('(flag_string = ?) and wxuin = ?', '*', wx_data['wxuin']).first
        unless auto_reply_g.blank?
          if auto_reply_g.content != 'tl' # 全局非图灵机器人
            base[:Msg][:Content] = auto_reply_g.content
            @wx.send_msg(wx_data['pass_ticket'], base, cookies)
          else
            @wx.char_with_tuliung wx_data['pass_ticket'], base, cookies, from_user, content # 全局图灵机器人
          end
        end
      end
    elsif from_user[0,2] == '@@' && from_user != wx_data['UserName'] # 群聊
      # TODO 判断缓存中是否存在该群组，如果不存在 获取并保存
      # TODO 群显示名称？ ‘昵称’？ ‘微信名’
      groups = begin
        JSON.parse $redis.get("wxRot_##{wx_data['wxuin']}#groups")
      rescue
         []
      end

      if groups.blank?
        # 重新获取群组
      else
        groups.each do |g|
          if g['UserName'] == from_user
            g['MemberList'].each do |m|
              if m['UserName'] == wx_data['UserName']
                display_name = m['DisplayName']
                display_name = m['NickName'] if display_name.blank?
                if content.include? "@#{display_name} " # 包含@我的信息
                    # from who
                  user = content.split(':')[0]

                  # TODO 自动回复
                end
              end
            end
          end
        end
      end
    end
  end

  # 处理个人的自动回复
  def auto_reply(msg, wx_data, cookies)
    # from_user = msg['FromUserName']
    # to_user = msg['ToUserName']
    # content = msg['Content'].gsub('br/', '/n').strip
    # msg_id =  "#{Time.now.to_i}#{rand.to_s[0,5]}".gsub('.','')
    # base = {
    #   BaseRequest: { Uin: wx_data['wxuin'],Sid: wx_data['wxsid'] , Skey: wx_data['skey'], DeviceID: "e#{rand(999999999999999)}"},
    #   Msg: { ClientMsgId: msg_id, FromUserName: to_user, LocalID: msg_id, ToUserName: from_user, Type: 1 },
    #   Scene: 0
    # }
    # if from_user[0,2] != '@@' && from_user != wx_data['UserName'] # 私聊
    #   auto_reply = AutoReply.where('flag_string = ? and wxuin = ?', content, wx['wxuin']).first
    #   unless auto_reply.blank?
    #     base[:Msg][:Content] = auto_reply.content
    #     @wx.send_msg(wx_data['pass_ticket'], base, cookies) if Friend.where(id: auto_reply.id, UserName: from_user).exists?
    #     return true
    #   end
    # end
    false
  end
end
