Rails.application.routes.draw do
  require 'sidekiq/web'
  root 'index#index'
  post 'sessions', to: 'sessions#create'
  post 'delete', to: 'sessions#destroy'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  namespace :api do
    namespace :v1 do
      get 'weixins/qr', to: 'weixins#qr'
      get 'weixins/login', to: 'weixins#login'
      get 'weixins/tickets', to: 'weixins#get_tickets'
      # get 'uuid', to: 'login#get_uuid'
      # get 'qr', to: 'login#get_qr'
      # get 'login', to: 'login#login'
      # get 'tickets', to: 'login#get_tickets'
      get 'weixins/message_id', to: 'weixins#message_id'
      post 'weixins/init', to: 'weixins#weixinInit'
      post 'weixins/save', to: 'weixins#save_weixin'
      get 'friends/friends', to: 'friends#friends'
      post 'auto_replies', to: 'auto_replies#create'
      delete 'auto_replies/:id', to: 'auto_replies#destroy'
      post 'auto_reply_globals', to: 'auto_reply_globals#create'
      delete 'auto_reply_globals/:id', to: 'auto_reply_globals#destroy'

    end
  end

  namespace :admin do
    mount Sidekiq::Web, at: '/sidekiq'
    get '/', to: 'index#index'
    get 'weixins', to: 'weixins#index'
    get 'weixins/edit', to: 'weixins#edit', as: :weixins_edit
    get 'weixins/groups', to: 'weixins#groups', as: 'weixins_groups'
    post 'weixins/msg-tran', to: 'weixins#msg_tran', as: 'msg_tran'
    delete 'weixins/tran-remove', to: 'weixins#tran_remove'
    resources :auto_replies
    resources :auto_reply_globals
  end
end
