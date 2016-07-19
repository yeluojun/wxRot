class Api::V1::WeixinsController < Api::V1::BasesController
  before_action :set_wx

  # 获取微信二维码
  def qr
    @uuid = @wx.get_uuid
    @tr = @wx.get_qr(@uuid)
    render json: { code: 200, msg: 'get qr success', data: @uuid }
  end

  # 微信登陆
  def login
    @code, @data = @wx.login_wx(params[:uuid])
    render json: { code: @code, data: @data }
  end

  # 获取票据
  def get_tickets
    @data, @cookies = @wx.get_tickets(params[:uuid], params[:ticket], params[:scan])
    render json: { code: 200, data: @data, cookies: @cookies }
  end

  # 获取微信message id
  def message_id
    @data = @wx.get_wx_message_id params[:ticket]
    render json: { code: 200, data: @data }
  end

  # 微信初始化
  def weixinInit
    @data = @wx.wx_init(params[:pass_ticket], params[:base])
    wx = params[:weixin]
    wx[:UserName] = @data['User']['UserName']
    wx[:NickName] = @data['User']['NickName']
    wx[:cookies] = params[:cookies]

    # 保存好友列表
     save_friends_thread = Thread.new do
       begin
         data = JSON.parse @wx.get_wx_contact_member_list wx['pass_ticket'], wx['skey'], params[:cookies]
         return render json: { code: 500, msg: '微信初始化失败: 获取联系人失败' } if data['BaseResponse']['Ret'].to_i == 1
         $redis.set("wxRot_##{wx[:wxuin]}#friends", data['MemberList'].to_json)
       rescue => ex
         return render json: { code: 500, msg: "微信初始化失败: #{ex.message}" }
       end
     end

    # 保存群组列表
    sve_group_thread = Thread.new do
      group_list = []
      @data['ContactList'].each do |c|
        if c['UserName'][0,2] == '@@'
          group_list.push({ EncryChatRoomId: '', UserName: c['UserName'] })
        end
      end
      base = {
        BaseRequest: { Uin: wx['wxuin'],Sid: wx['wxsid'] , Skey: wx['skey'], DeviceID: "e#{rand(999999999999999)}"},
        count: group_list.length,
        List: group_list
      }
      data = @wx.get_wx_batchget_contact wx['pass_ticket'],base , params[:cookies]
      $redis.set("wxRot_##{wx[:wxuin]}#groups", data['ContactList'].to_json)
    end

    save_friends_thread.join
    sve_group_thread.join

    # 保存 微信一系列票据
    $redis.set("wxRot_list##{wx[:wxuin]}", wx.to_json)
    $redis.expire("wxRot_list##{wx[:wxuin]}", 300)

    Thread.new do
      WxHeartJob.perform_now({synckey: @data['SyncKey'], uin: wx[:wxuin], cookies: params[:cookies]})  # 开启微信心跳的任务
    end
    render json: { code: 200, data: @data }
  end

  private

  def set_wx
    @wx =  WxApi::Wx.new
  end
end
