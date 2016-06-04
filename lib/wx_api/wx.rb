require 'rest-client'
require 'json'
require 'active_support/all'
# require 'ha'
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
          @tickets = get_url_params redis_url
          break
        else
          puts 'login failed', data # login failed
        end
      end
      p @tickets
      @tickets
    end

    # 获取各种身份验证信息
    def get_tickets(uuid, ticket, scan)
      url= "https://wx.qq.com/cgi-bin/mmwebwx-bin/webwxnewloginpage?ticket=#{ticket}&uuid=#{uuid}&lang=zh_CN&scan=#{scan}&fun=new&version=v2&lang=zh_CN"
      data = RestClient::Request.execute(method: :get, url: url)
      data = Hash.from_xml(data)
      # {"error"=>{"ret"=>"0", "message"=>"OK", "skey"=>"@crypt_9b7299e2_793a0a9fd7afaade20eaea9937e0a717",
      #            "wxsid"=>"H0/ch7t+S6a2LVsH", "wxuin"=>"608120400",
      #            "pass_ticket"=>"6Bk%2BWmSIOkEoiba6bUS%2BG6ijPwOkeDmVatpkqNmknrY%2BusWbGLnu9NFEKvXEF1tk",
      #            "isgrayscale"=>"1"}}

      data['error']
    end

    # 微信初始化
    def wx_init(pass_ticket)
      url = "https://wx.qq.com/cgi-bin/mmwebwx-bin/webwxinit?r=-#{Time.now.to_i}&lang=zh_CN&pass_ticket=#{pass_ticket}"
      data = RestClient::Request.execute(method: :get, url: url)
      JSON.parse data
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