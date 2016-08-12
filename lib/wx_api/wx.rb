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
      @file = File.new("#{Rails.root}/public/qrs/#{uuid}.png", 'wb')
      # @file = File.new("aaa.png", 'wb')
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
      # loop do
        url = "https://login.wx.qq.com/cgi-bin/mmwebwx-bin/login?loginicon=true&uuid=#{uuid}&tip=#{tip}&_=#{Time.now.to_i}&r=-#{Time.now.to_i}"
        data = RestClient::Request.execute(method: :get, url: url)
        if data.include? 'window.code=200'
          puts 'login success' # login success
          redis_url = data.split(/\"/)[1]
          @tickets = get_url_params redis_url
          # break
          return [200, @tickets]
        elsif data.include? 'window.code=400'
          puts 'login failed', data # login failed
          return [400, @tickets]
        else
          return [408, @tickets]
        end
      # end
    end

    # 获取各种身份验证信息
    def get_tickets(uuid, ticket, scan)
      url= "https://wx.qq.com/cgi-bin/mmwebwx-bin/webwxnewloginpage?ticket=#{ticket}&uuid=#{uuid}&lang=zh_CN&scan=#{scan}&fun=new&version=v2&lang=zh_CN"
      data = RestClient::Request.execute(method: :get, url: url)
      cookies = data.cookies
      data = Hash.from_xml(data)
      [data['error'], cookies]
    end

    # 微信初始化
    def wx_init(pass_ticket, permit_params)
      url = "https://wx.qq.com/cgi-bin/mmwebwx-bin/webwxinit?r=-#{Time.now.to_i}&lang=zh_CN&pass_ticket=#{pass_ticket}"
      data = RestClient.post(url,  permit_params.to_json, {'Content-Type' =>'application/json' })
      JSON.parse data
    end

    # 获取微信id
    def get_wx_message_id(pass_ticket)
      url = "https://wx.qq.com/cgi-bin/mmwebwx-bin/webwxstatusnotify?pass_ticket=#{pass_ticket}"
      JSON.parse RestClient::Request.execute(method: :get, url: url)
    end

    # 获取联系人列表
    def get_wx_contact_member_list(pass_ticket, skey, cookies)
      url = "https://wx.qq.com/cgi-bin/mmwebwx-bin/webwxgetcontact?pass_ticket=#{pass_ticket}&r=#{Time.now.to_i}&seq=0&skey=#{skey}"
      RestClient.get url, cookies: cookies
    end

    # 这里主要用来获取群组的列表
    def get_wx_batchget_contact(pass_ticket, params, cookies)
      url = "https://wx.qq.com/cgi-bin/mmwebwx-bin/webwxbatchgetcontact?type=ex&r=#{Time.now.to_i}&lang=en_US&pass_ticket=#{pass_ticket}"
      RestClient.post url, params.to_json, cookies: cookies
    end

    # 搜索接口 (没有用)
    def search_contacts(wx_data, cookies, params)
      url = "https://wx.qq.com/cgi-bin/mmwebwx-bin/webwxsearchcontact?sid=#{wx_data['wxsid']}&skey=#{wx_data['skey']}&lang=en_US&pass_ticket=#{wx_data[:pass_ticket]}&seq=0&r=#{Time.now.to_i}"
      RestClient.post(url,  params.to_json , cookies: cookies)
    end

    # 检查 (类似心跳)
    def synccheck(params, cookies)
      url = 'https://webpush.wx.qq.com/cgi-bin/mmwebwx-bin/synccheck'
      RestClient.get(url, params: params, cookies: cookies)
    end

    # 获取微信更新(各种更新.包括新消息等等)
    def webwxsync(wx_data, params, cookies)
      url = "https://wx.qq.com/cgi-bin/mmwebwx-bin/webwxsync?sid=#{wx_data['wxsid']}&skey=#{wx_data['skey']}&lang=en_US&pass_ticket=#{wx_data[:pass_ticket]}"
      RestClient.post(url, params.to_json, cookies: cookies)
    end

    # 发送文字信息
    def send_msg(pass_ticket, params, cookies)
      url = "https://wx.qq.com/cgi-bin/mmwebwx-bin/webwxsendmsg?pass_ticket=#{pass_ticket}"
      RestClient.post(url, params.to_json)
    end

    # 接收添加好友的邀请
    # params: {
    # BaseRequest: {}
    # Opcode: 3
    # SceneList:[33]
    # SceneListCount:1
    # VerifyContent:""
    # VerifyUserList [{ Value, VerifyUserTicket}]
    # VerifyUserListSize: 1
    # skey : "@crypt_9e0f187f_9115a1ded938bb043072de90a77e9d42"
    # }
    def friend_request_accept(pass_ticket, params, cookies)
      p 'add friend params: ',  params
      url = "https://wx.qq.com/cgi-bin/mmwebwx-bin/webwxverifyuser?r=#{Time.now.to_i}&pass_ticket=#{pass_ticket}"
      RestClient.post(url, params.to_json, cookies)
    end


    # 图灵机器人聊天
    def char_with_tuliung(pass_ticket, params, cookies, user_name, question, display_name = nil)
      @tl = TuLing::Tl.new
      begin
        ret = JSON.parse @tl.chat_with_tl(question, '', user_name.get_all_num )
        case ret['code'].to_i
          when 100000
            params[:Msg][:Content] = ret['text']
            params[:Msg][:Content] = display_name + params[:Msg][:Content] unless display_name.blank?
            send_msg(pass_ticket, params, cookies)
          when 200000
            params[:Msg][:Content] = "#{ret['text']}\n#{ret['url']}"
            params[:Msg][:Content] = display_name + params[:Msg][:Content] unless display_name.blank?
          when 302000
            text = ret['text'] + "\n\n"
            ret['list'].each do |l|
              text += "[#{ l['source'] }]#{l['article']}\n链接：#{l['detailurl']}\n\n"
            end
            params[:Msg][:Content] = text
            params[:Msg][:Content] = display_name + params[:Msg][:Content] unless display_name.blank?
            send_msg(pass_ticket, params, cookies)
          when 308000
            text = ret['text'] + "\n\n"
            ret['list'].each do |l|
              text += "名称：#{l['name']}\n配料：#{l['info']}\n链接：#{l['detailurl']} \n\n"
            end
            params[:Msg][:Content] = text
            params[:Msg][:Content] = display_name + params[:Msg][:Content] unless display_name.blank?
            send_msg(pass_ticket, params, cookies)
          else
            params[:Msg][:Content] = '抱歉，机器人死掉了　＝．＝'
            params[:Msg][:Content] = display_name + params[:Msg][:Content] unless display_name.blank?
            send_msg(pass_ticket, params, cookies)
        end
      rescue => ex
        p '错误是: ',ex.message
        params[:Msg][:Content] = '抱歉，机器人死掉了　＝．＝'
        params[:Msg][:Content] = display_name + params[:Msg][:Content] unless display_name.blank?
        send_msg(pass_ticket, params, cookies)
      end
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
