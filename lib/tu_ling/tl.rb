module TuLing
  class Tl
    def initialize
      @base_url = 'http://www.tuling123.com/openapi/api'
      @api_key = 'cb0e4e124b15f6090ec8e25d2bb2be6a'
    end


    def chat_with_tl(info, loc = '',  user_id = '')
      params = {
        key: @api_key,
        info: info,
      }
      params[:loc] = loc unless loc.blank?
      params[:userid] = user_id.to_s unless user_id.blank?
      RestClient.post(@base_url, params)
    end
  end
end