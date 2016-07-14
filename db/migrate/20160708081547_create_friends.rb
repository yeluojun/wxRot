class CreateFriends < ActiveRecord::Migration[5.0]
  def change
    create_table :friends do |t|
      t.string :wxuin
      t.string :Uin # 微信那边的唯一标记
      t.string :UserName # 加密的名称
      t.string :NickName # 昵称
      t.string :HeadImgUrl # 头像
      t.string :ContactFlag #
      t.string :MemberCount #
      t.string :RemarkName #
      t.string :HideInputBarFlag #
      t.string :Sex #
      t.text :Signature #
      t.string :VerifyFlag #
      t.string :OwnerUin #
      t.text :PYInitial #
      t.text :PYQuanPin #
      t.text :RemarkPYInitial  #
      t.string :StarFriend  #
      t.string :AppAccountFlag  #
      t.string :Statues  #
      t.string :AttrStatus  #
      t.string :Province  #
      t.string :City  #
      t.string :Alias  #
      t.string :SnsFlag  #
      t.string :UniFriend  #
      t.string :DisplayName  #
      t.string :ChatRoomId  #
      t.string :KeyWord  #
      t.string :EncryChatRoomId  #
      t.timestamps
    end
  end
end
