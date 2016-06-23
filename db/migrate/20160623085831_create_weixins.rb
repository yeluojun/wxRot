class CreateWeixins < ActiveRecord::Migration[5.0]
  def change
    create_table :weixins do |t|
      t.string :name # 名称
      t.string :encry_name # 加密名称
      t.string :wx_id # 微信那边的id
      t.timestamps
    end
  end
end
