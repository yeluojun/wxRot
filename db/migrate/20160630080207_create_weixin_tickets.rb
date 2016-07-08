class CreateWeixinTickets < ActiveRecord::Migration[5.0]
  def change
    create_table :weixin_tickets do |t|
      t.string :wxuin
      t.text :json_data
      t.timestamps
    end
  end
end
