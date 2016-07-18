class CreateChatHistories < ActiveRecord::Migration[5.0]
  def change
    create_table :chat_histories do |t|
      t.string :MsgId
      t.string :FromUserName
      t.string :ToUserName
      t.string :MsgType
      t.text :Content
      t.string :wxuin
      t.timestamps
    end
  end
end
