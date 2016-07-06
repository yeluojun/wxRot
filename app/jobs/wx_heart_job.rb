class WxHeartJob < ApplicationJob
  queue_as :default

  # 心跳包任务
  def perform(*args)
    params = args.first
    uin, synckey  = params[:uin], params[:synckey]
    loop do

      weixin = WeixinTicket.where(wx_id: uin).first
      break if weixin.blank?
      begin
        wx_data = JSON.parse weixin.json_data
      rescue => ex
        break
      end

      params = {
        _: Time.now.to_i + 1000,
        r: Time.now.to_i,
        deviceid: "e#{rand(999999999999999)}",
        sid: wx_data['wxsid'],
        skey: wx_data['skey'],
        synckey: synckey,
        uin: uin
      }
      url = 'https://webpush.wx.qq.com/cgi-bin/mmwebwx-bin/synccheck'
      begin
        data = JSON.parse RestClient.get(url, params: params)
        p '微信那边返回的数据是:', data
      rescue => ex
        break
      end

      sleep 2000
    end
    # 路径
  end
end
