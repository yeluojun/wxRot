Rails.application.routes.draw do
  root 'index#index'
  post 'sessions', to: 'sessions#create'
  post 'delete', to: 'sessions#destroy'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  namespace :api do
    namespace :v1 do
      get 'weixins/qr', to: 'weixins#qr'
      get 'weixins/login', to: 'weixins#login'
      get 'weixins/tickets', to: 'weixins#get_tickets'
      get 'uuid', to: 'login#get_uuid'
      get 'qr', to: 'login#get_qr'
      get 'login', to: 'login#login'
      get 'tickets', to: 'login#get_tickets'
    end
  end

  namespace :admin do
    get '/', to: 'index#index'
    get 'weixins', to: 'weixins#index'
  end
end
