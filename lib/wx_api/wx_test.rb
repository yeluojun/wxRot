require 'minitest/autorun'
require_relative 'wx'

class WxTest < MiniTest::Unit::TestCase
  def setup
    @wx_api = WxApi::Wx.new
    @uuid = @wx_api.get_uuid
  end

  def test_get_uuid
    data = @wx_api.get_uuid
    p data
  end

  def test_get_qr
    data = @wx_api.get_qr @uuid
    p data
  end

  def test_login_wx
    data = @wx_api.get_qr @uuid
    p data
    @wx_api.login_wx @uuid, 0
  end

  def test_get_tickets
     @wx_api.get_qr @uuid
     data =  @wx_api.login_wx @uuid, 0
     data, cookies = @wx_api.get_tickets(@uuid, data['ticket'], data['scan'])
     @wx_api.wx_init data['pass_ticket'], { Uin: data['wxuin'], Sid: data['wxsid'], Skey: data['skey'], DeviceID: 'e15920363777' }, cookies
  end

  # 测试回去微信消息的id
  def test_get_wx_message_id
    @wx_api.get_qr @uuid
    data =  @wx_api.login_wx @uuid, 0
    data, cookies = @wx_api.get_tickets(@uuid, data['ticket'], Time.now.to_i)
    p @wx_api.wx_init data['pass_ticket'], { Uin: data['wxuin'], Sid: data['wxsid'], Skey: data['skey'], DeviceID: 'e1615250492' },cookies
    # p @wx_api.get_wx_message_id(data['pass_ticket'])
  end

  def test_get_url_params
    data = @wx_api.get_url_params("https://wx.qq.com/cgi-bin/mmwebwx-bin/webwxnewloginpage?ticket=Afxs5izFoHECKjw6b1lzpyTt@qrticket_0&uuid=wfp3wF_TMg==&lang=zh_CN&scan=1464945770")
  end

end