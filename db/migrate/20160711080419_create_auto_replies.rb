class CreateAutoReplies < ActiveRecord::Migration[5.0]
  def change
    create_table :auto_replies do |t|
      t.string :wxuin
      t.integer :friend_id
      t.string :flag_string
      t.string :content
      t.timestamps
    end
  end
end
