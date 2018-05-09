#!/usr/bin/env puma

require 'etc'

env = ENV.fetch("RAILS_ENV") { "production" }
environment env

deploy_to = File.expand_path('../' * 3, __FILE__)
directory "#{deploy_to}/current"
rackup "#{deploy_to}/current/config.ru"
pidfile "#{deploy_to}/shared/tmp/pids/puma.pid"
state_path "#{deploy_to}/shared/tmp/sockets/puma.state"
stdout_redirect "#{deploy_to}/shared/log/puma_access.log", "#{deploy_to}/shared/log/puma_error.log", true
bind "unix://#{deploy_to}/shared/tmp/sockets/puma.sock"
activate_control_app "unix://#{deploy_to}/shared/tmp/sockets/pumactl.sock"

port 5052

threads 0, 2

workers Etc.nprocessors

prune_bundler

on_restart do
  puts 'Refreshing Gemfile'
  ENV["BUNDLE_GEMFILE"] = "#{deploy_to}/current/Gemfile"
end
