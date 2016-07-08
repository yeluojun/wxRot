class CreateFriends < ActiveRecord::Migration[5.0]
  def change
    create_table :friends do |t|
      t.string :wxuin # 微信那边的唯一标记
      t.string :encry_name # 加密的名称
      t.string :nickname # 昵称
      t.string :user_type # 用户类型
      t.string :remark_name # 备注名称
      t.string :signature # 个性签名
      t.string :head_img_url # 头像
      t.timestamps
    end
  end
end
