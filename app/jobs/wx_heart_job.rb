class WxHeartJob < ApplicationJob
  queue_as :default

  # 心跳包任务
  def perform(*args)
    params = args.first
    uin, synckey, cookies  = params[:uin], params[:synckey], params[:cookies]
    weixin = WeixinTicket.where(wx_uid: uin).order('id desc').first
    return if weixin.blank?
    begin
      wx_data = JSON.parse weixin.json_data
    rescue => ex
      p 'db error is :', ex.message
      return
    end
    # 更新机器人状态
    rob = Weixin.where(wx_id: uin).first
    if rob.blank?
      Weixin.create!(wx_id: uin, status: 1, name: wx_data['NickName'], encry_name: wx_data['UserName']) # 创建一个正在运行的机器人
    else
      rob.update(status: 1, name: wx_data['NickName'], encry_name: wx_data['UserName']) # 更新机器人状态
    end

    loop do
      params = {
        _: Time.now.to_i + 1000,
        r: Time.now.to_i,
        deviceid: "e#{rand(999999999999999)}",
        sid: wx_data['wxsid'],
        skey: wx_data['skey'],
        synckey: synckey,
        uin: uin
      }
      wx_data['skey'] = URI::encode(wx_data['skey'])
      wx_data['skey'][0] = '%40'
      url = 'https://webpush.wx.qq.com/cgi-bin/mmwebwx-bin/synccheck'
      begin
        data = RestClient.get(url, params: params, cookies: cookies)
        if data.include? '1100' #失败 or 退出登陆了
          rob.update!(status: 0)
          # 更新机器人状态
        elsif data.include? "selector:\"0\""
          # do nothing
        else
          # 获取更新
          url = ""
        end
      rescue => ex
        p 'some error:', ex.message
        rob.update!(status: 0)
        break
      end
      sleep 2
    end
  end
end
