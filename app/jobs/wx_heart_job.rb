class WxHeartJob < ApplicationJob
  queue_as :default

  # 心跳包任务
  def perform(*args)
    p 'ping ping'
    @wx =  WxApi::Wx.new
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
    $redis.expire(uin, 300)

    # 保存cookie
      $redis.set("wxRot_cookies##{uin}", cookies)
    $redis.expire(uin, 300)

    # 获取所有的联系人列表
    Thread.new do
      data = JSON.parse @wx.get_wx_contact_member_list wx_data['pass_ticket'], wx_data['skey'], cookies

      # 更新联系人列表
      data['MemberList'].each do |ret|
        user = Friend.where(UserName: ret['UserName'], wxuin: uin).first
        params = Friend.params ret
        params[:wxuin] = uin
        if user.blank?
          user = Friend.new(params)
          user.save
        else
          user.update(params)
        end
      end
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
          params[:synckey] =  syn_string = syn_string.chop
        end
      rescue => ex
        p 'some error:', ex.message
        rob.update!(status: 0)
        break
      end
      $redis.expire("wxRot_list##{uin}", 300)
      $redis.expire("wxRot_cookies##{uin}", 300)
      sleep 2
    end
  end
end
