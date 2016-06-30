class AutoReplyJob < ApplicationJob
  queue_as :default

  # 自动回复任务
  def perform(*args)
    # Do something later
  end
end
