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
      @code, @data = @wx.login_wx(params[:uuid])
    end
    t.join
    if t.blank?
      render json: { code: @code, data: @data}
    end
  end

  def set_wx
    @wx =  WxApi::Wx.new
  end
end
