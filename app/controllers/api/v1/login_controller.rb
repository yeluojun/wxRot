class Api::V1::LoginController < ApplicationController
  before_action :set_wx
  def get_uuid
    render json: { code: 200, data: @wx.get_uuid}
  end
  def get_qr
    t = Thread.new do
      @tr = @wx.get_qr(params[:uuid])
    end
    t.join
    render json: { code: 200, data: @tr }
  end

  def login
    t = Thread.new do
      p 'time start: ', Time.now.to_i
      @code, @data = @wx.login_wx(params[:uuid])
      p 'time end: ', Time.now.to_i
    end
    t.join
    render json: { code: @code, data: @data}
  end

  def wx_init

  end

  def set_wx
    @wx =  WxApi::Wx.new
  end
end
