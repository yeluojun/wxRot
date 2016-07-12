class AutoReply < ApplicationRecord
  belongs_to :friend
  attr_accessor :user_str
  validates :friend_id, presence: { message: '好友id不能为空' }
  validates :flag_string, presence: { message: '标记不能为空' }
  validates :wxuin, presence: { message: '微信标识不能为空' }
  validates :content, presence: { message: '自动回复的内容不能为空' }
end
