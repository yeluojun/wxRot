class CreateAutoReplyGlobals < ActiveRecord::Migration[5.0]
  def change
    create_table :auto_reply_globals do |t|
      t.string :wxuin, null: false
      t.integer :flag, default: 0, null: false , comment: '0表示普通全局回复1表示@'
      t.string :flag_string, null: false
      t.string :content, null: false
      t.timestamps
    end
  end
end
