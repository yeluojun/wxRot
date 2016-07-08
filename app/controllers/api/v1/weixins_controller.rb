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
    data_exist = WeixinTicket.where(wxuin: wx[:wxuin]).first
    if data_exist.blank?
      WeixinTicket.create!(wxuin: wx[:wxuin], json_data: wx.to_json)
    else
      data_exist.update!(json_data: wx.to_json)
    end
    Thread.new do
      WxHeartJob.perform_now({synckey: @data['SyncKey'], uin: wx[:wxuin], cookies: params[:cookies]})  # 开启微信心跳的任务
    end
    render json: { code: 200, data: @data }
  end

  # save_wx_ticket: 保存微信各种ticket数据到数据库
  def save_weixin
    data_exist = WeixinTicket.where(wxuin: params[:wx][:wxuin]).first
    if data_exist.blank?
      WeixinTicket.create!(wxuin: params[:wx][:wx_uid], json_data: params[:wx].to_json)
    else
      data_exist.update!(json_data: params[:wx].to_json)
    end
  end

  private

  def set_wx
    @wx =  WxApi::Wx.new
  end
end
