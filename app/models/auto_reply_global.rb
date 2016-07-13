class AutoReplyGlobal < ApplicationRecord
  validates :flag_string, presence: { message: '标记不能为空' }
  validates :content, presence: { message: '回复内容不能为空' }
  validates :wxuin, presence: { message: '微信标识不能为空' }

  attr_accessor :reply_flag
end
