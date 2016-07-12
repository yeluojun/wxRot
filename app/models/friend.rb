class Friend < ApplicationRecord
  has_many :auto_replies
  class << self
    def params(data)

      {
        Uin: data['Uin'],
        UserName: data['UserName'],
        NickName: data['NickName'],
        HeadImgUrl: data['HeadImgUrl'],
        ContactFlag: data['ContactFlag'],
        MemberCount: data['MemberCount'],
        RemarkName: data['RemarkName'],
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
  end
end
