class CreateWeixins < ActiveRecord::Migration[5.0]
  def change
    create_table :weixins do |t|
      t.string :name # 名称
      t.string :encry_name # 加密名称
      t.string :wxuin # 微信那边的id
      t.integer :status, default: 0 # 运行状态, 默认是非运行状态
      t.timestamps
    end
  end
end
