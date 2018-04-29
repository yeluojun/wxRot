c = {
  url:             Rails.application.secrets.redis_sidekiq,
  namespace:       'Sidekiq',
  network_timeout: 3,
}

Sidekiq.configure_server do |config|
  config.redis = c
  # config.average_scheduled_poll_interval = 5

  # Sidekiq::Cron::Job.destroy_all!
  # CronJob.set!
end

Sidekiq.configure_client do |config|
  config.redis = c
end

# Sidekiq.default_worker_options = {
#   'retry'     => 5,
#   'backtrace' => false,
#   'queue'     => 'xdl_default',
# }
