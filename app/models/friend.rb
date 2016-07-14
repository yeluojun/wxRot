class Friend < ApplicationRecord
  has_many :auto_replies, dependent: :destroy
  class << self
    def params(data)
      {
        Uin: data['Uin'],
        UserName: data['UserName'],
        NickName: resolving_emoji(data['NickName']),
        HeadImgUrl: data['HeadImgUrl'],
        ContactFlag: data['ContactFlag'],
        MemberCount: data['MemberCount'],
        RemarkName: resolving_emoji(data['RemarkName']),
        HideInputBarFlag: data['HideInputBarFlag'],
        Sex: data['Sex'],
        Signature: data['Signature'],
        VerifyFlag: data['VerifyFlag'],
        OwnerUin: data['OwnerUin'],
        PYInitial: data['PYInitial'],
        PYQuanPin: data['PYQuanPin'],
        RemarkPYInitial: data['RemarkPYInitial'],
        StarFriend: data['StarFriend'],
        AppAccountFlag: data['AppAccountFlag'],
        Statues: data['Statues'],
        AttrStatus: data['AttrStatus'],
        Province: data['Province'],
        City: data['City'],
        Alias: data['Alias'],
        SnsFlag: data['SnsFlag'],
        UniFriend: data['UniFriend'],
        DisplayName: data['DisplayName'],
        ChatRoomId: data['ChatRoomId'],
        KeyWord: data['KeyWord'],
        EncryChatRoomId: data['EncryChatRoomId'],
      }
    end

    # 解析emoji表情
    def resolving_emoji(emoji)
      begin
        res = /<span.*?class="emoji emoji(.*?)"><\/span>/
        if res =~ emoji.to_s
          emoji = emoji.gsub(res, WeixinCommon::EMOJI_FACE_MAP["#{$1}"])
          emoji
        else
          emoji
        end
      rescue => ex
        emoji
      end
    end
  end
end
