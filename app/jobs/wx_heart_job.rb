class WxHeartJob < ApplicationJob
  queue_as :default

  # 心跳包任务
  def perform(*args)
    # Do something later
  end
end
