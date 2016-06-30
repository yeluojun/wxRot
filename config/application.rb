require_relative 'boot'

require "rails"
require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module WxRot
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
    config.i18n.available_locales = [:'zh-CN', :zh]
    config.i18n.default_locale = :'zh-CN'

    config.active_record.default_timezone = :local
    config.time_zone = 'Asia/Shanghai'
    config.encoding = 'utf-8'
    config.autoload_paths << Rails.root.join('lib')
    config.active_job.queue_adapter = :sidekiq
    config.middleware.insert_before 0, 'Rack::Cors', debug: true, logger: (-> { Rails.logger }) do
      allow do
        origins '*'
        resource '*',
                 headers: :any,
                 methods: [:get, :post, :delete, :put, :patch, :options, :head],
                 max_age: 0
      end
    end
  end
end
