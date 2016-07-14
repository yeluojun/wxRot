class WxHeartJob < ApplicationJob
  queue_as :default

  # 心跳包任务
  def perform(*args)
    p 'ping ping'

    @wx =  WxApi::Wx.new
    err_time = 0
    params = args.first
    uin, synckey, cookies  = params[:uin], params[:synckey], params[:cookies]

    syn_string = ''
    synckey['List'].each do |list|
      syn_string += "#{list['Key']}_#{list['Val']}|"
    end
    syn_string = syn_string.chop

    weixin = WeixinTicket.where(wxuin: uin).order('id desc').first
    return if weixin.blank?
    begin
      wx_data = JSON.parse weixin.json_data
    rescue => ex
      p 'db error is :', ex.message
      return
    end

    # 更新机器人状态
    rob = Weixin.where(wxuin: uin).first
    if rob.blank?
      Weixin.create!(wxuin: uin, status: 1, name: wx_data['NickName'], encry_name: wx_data['UserName']) # 创建一个正在运行的机器人
    else
      rob.update(status: 1, name: wx_data['NickName'], encry_name: wx_data['UserName']) # 更新机器人状态
    end

    # 保存
    $redis.set("wxRot_list##{uin}", wx_data.to_json)
    $redis.expire("wxRot_list##{uin}", 300)

    # 保存cookie
    $redis.set("wxRot_cookies##{uin}", cookies)
    $redis.expire("wxRot_cookies##{uin}", 300)

    # 获取所有的联系人列表
    Thread.new do
      data = JSON.parse @wx.get_wx_contact_member_list wx_data['pass_ticket'], wx_data['skey'], cookies

      # 更新联系人列表
      $redis.set("wxRot_MemberList##{uin}", data['MemberList'].to_json)
      $redis.expire("wxRot_MemberList##{uin}", 300)

      # data['MemberList'].each do |ret|
      #   begin
      #     user = Friend.where(wxuin: uin).delete_all
      #     params = Friend.params ret
      #     params[:wxuin] = uin
      #     if user.blank?
      #       user = Friend.new(params)
      #       user.save
      #     else
      #       user.update(params)
      #     end
      #   rescue => ex
      #     p 'update member list failed:', ex.message
      #   end
      # end
    end

    # 开启心跳之旅
    loop do
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
          rob.update!(status: 0) # 更新机器人状态
          break
        elsif data.include? "selector:\"0\""
          # do nothing
        else
          # 获取更新
          base = { BaseRequest: { Uin: wx_data['wxuin'],Sid: wx_data['wxsid'] , Skey: wx_data['skey'], DeviceID: "e#{rand(999999999999999)}"}, SyncKey: synckey , rr: Time.now.to_i }
          data = JSON.parse @wx.webwxsync wx_data, base, cookies

          # 更新 synckey
          syn_string = ''
          data['SyncKey']['List'].each do |list|
            syn_string += "#{list['Key']}_#{list['Val']}|"
          end
          params[:synckey] = syn_string = syn_string.chop

          # 保存聊天记录
          Thread.new do
            save_chat_history data['AddMsgList']
          end

          # 自动回复
          Thread.new do
            data['AddMsgList'].each do |msg|
              auto_reply_group msg
              ret = auto_reply_global msg
              auto_reply data['AddMsgList'] if !ret
            end
          end
        end
        err_time = 0
      rescue => ex
        err_time += 1
        if err_time >= 5
          p 'some error:', ex.message
            rob.update!(status: 0)
          break
        end
      end
      $redis.expire("wxRot_list##{uin}", 300)
      $redis.expire("wxRot_cookies##{uin}", 300)
      sleep 1
    end
    # TODO 等待子线程完成后再结束父级进程
  end

  # 保存聊天记录
  def save_chat_history(msg_array)
    msg_array.each do |msg|
      @history = CreateChatHistories.new({ MsgId: msg['MsgId'], FromUserName: msg['FromUserName'], ToUserName: msg['ToUserName'],MsgType: msg['MsgType'], Content: msg['MsgType'] })
      @history.save
    end
  end

  # 处理全局自动回复
  def auto_reply_global(msg_array)
    # 防止撤回

  end

  # 处理个人的自动回复
  def auto_reply(msg_array)

  end

  # 处理群聊@信息
  def auto_reply_group(msg_array)

  end

end
