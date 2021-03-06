require 'mina/rails'
require 'mina/git'
require 'mina_sidekiq/tasks'
# require 'mina/rbenv'  # for rbenv support. (https://rbenv.org)
require 'mina/rvm'    # for rvm support. (https://rvm.io)
require 'mina/puma'

set :domain, 'root@yeluojun.club'
set :deploy_to, '/deploy/rails/wxRot'
set :repository, 'git@github.com:yeluojun/wxRot.git'
set :branch, 'master'
set :rails_env, 'production'


set :application_name, 'wxRot'

set :rvm_use_path, "/usr/local/rvm/scripts/rvm"
# Optional settings:
#   set :user, 'foobar'          # Username in the server to SSH to.
#   set :port, '30000'           # SSH port number.
#   set :forward_agent, true     # SSH forward_agent.

set :shared_files, fetch(:shared_files, []).push('config/database.yml', 'config/secrets.yml')

set :puma_config, -> { "#{fetch(:current_path)}/config/mina.puma.rb" }

task :remote_environment do
  invoke :'rvm:use', 'ruby-2.4.1'
end

# Put any custom commands you need to run at setup
# All paths in `shared_dirs` and `shared_paths` will be created on their own.
task :setup do
  task :setup do
    # command %{rbenv install 2.3.0 --skip-existing}
    command %(mkdir -p "#{fetch(:shared_path)}/pids/")
    command %[chmod g+rx,u+rwx "#{fetch(:shared_path)}/pids"]
    command %[mkdir -p "#{fetch(:shared_path)}/log"]
    command %[chmod g+rx,u+rwx "#{fetch(:shared_path)}/log"]
    comment "mkdir log #{fetch(:shared_path)}/log"

    command %[mkdir -p "#{fetch(:shared_path)}/config"]
    command %[chmod g+rx,u+rwx "#{fetch(:shared_path)}/config"]

    command %[mkdir -p "#{fetch(:shared_path)}/tmp/pids"]
    command %[chmod g+rx,u+rwx "#{fetch(:shared_path)}/tmp/pids"]

    command %[mkdir -p "#{fetch(:shared_path)}/tmp/sockets"]
    command %[chmod g+rx,u+rwx "#{fetch(:shared_path)}/tmp/sockets"]

    command %[touch "#{fetch(:shared_path)}/config/database.yml"]
    command %[touch "#{fetch(:shared_path)}/config/secrets.yml"]
    comment "Be sure to edit '#{fetch(:shared_path)}/config/database.yml', 'secrets.yml'"
  end
end

desc "Deploys the current version to the server."
task :deploy do
  invoke :'git:ensure_pushed'
  deploy do
    invoke :'git:clone'
    invoke :'deploy:link_shared_paths'
    invoke :'bundle:install'
    invoke :'rails:db_migrate'
    comment %{npm install~~~~~~~~~~~~~~~~~~~}
    command %[ source ~/.nvm/nvm.sh ]
    command %[npm install]
    invoke :'rails:assets_precompile'
    invoke :'deploy:cleanup'
    on :launch do
      invoke :'puma:phased_restart'
      invoke :'puma:start'
      invoke :'sidekiq:restart'
    end
  end
end

# For help in making your deploy script, see the Mina documentation:
#
#  - https://github.com/mina-deploy/mina/tree/master/docs
