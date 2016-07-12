class CreateTimingReplies < ActiveRecord::Migration[5.0]
  def change
    create_table :timing_replies do |t|
      t.string :wxuin, null: false
      t.string :flag_string, null: false
      t.string :content, null: false
      t.datetime :do_at, comment: '特定的时间'
      t.integer :timeing_reply, default: 1, comment: '定时的时间间隔'
      t.string :timeing_unit, default: 'h', comment: 'm表示分钟, h表示小时, d表示天'
      t.integer :friend_id, default: 0, comment: '0表示全局回复, 其他表示对单个朋友回复'
      t.integer :status, default: 0
      t.timestamps
    end
  end
end
