require 'rest-client'
require 'json'
module WxApi
  class Wx

    # 获取二维码
    def get_qr(uuid)
      url = "https://login.weixin.qq.com/qrcode/#{uuid}"
      data = RestClient::Request.execute(
          method: :get,
          url: url,
          cookies: {pgv_pvi: '1552874496', pgv_pvid: '3477447358', pgv_si: 's7350482944'})
      @file = File.new("a.png", 'wb')
      @file << data
      @file.close
      true
    end

    # 获取UUID
    def get_uuid
      url = "https://login.wx.qq.com/jslogin?appid=wx782c26e4c19acffb&redirect_uri=https%3A%2F%2Fwx.qq.com%2Fcgi-bin%2Fmmwebwx-bin%2Fwebwxnewloginpage&fun=new&lang=zh_CN&_=#{Time.now.to_i}"
      data = RestClient::Request.execute(method: :get, url: url)
      data.split(/\"/)[1]
    end

    # 登陆微信
    def login_wx(uuid, tip = 0)
      loop do
        url = "https://login.wx.qq.com/cgi-bin/mmwebwx-bin/login?loginicon=true&uuid=#{uuid}&tip=#{tip}&_=#{Time.now.to_i}&r=-#{Time.now.to_i}"
        data = RestClient::Request.execute(method: :get, url: url)
        if data.include? 'window.code=200'
          puts 'login success' # login success
          redis_url = data.split(/\"/)[1]
          @tickets =   get_url_params redis_url
        else
          puts 'login failed', data # login failed
        end
        @tickets
      end
    end

    # 获取各种身份验证信息
    def get_tickets(uuid, ticket, scan)
      url= "https://wx.qq.com/cgi-bin/mmwebwx-bin/webwxnewloginpage?ticket=#{ticket}&uuid=#{uuid}&lang=en_US&scan=#{scan}&fun=new&version=v2&lang=en_US"
    end


    private

    def get_url_params(url)
      params = {}
      url_format_params = url.split('?')[1]
      params_key_value_array = url_format_params.split('&')
      params_key_value_array.each do |p|
        p_array = p.split('=')
        params["#{p_array[0]}"] = p_array[1]
      end
     params
    end
  end
end