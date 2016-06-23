Rails.application.routes.draw do
  root 'index#index'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  namespace :api do
    namespace :v1 do
      get 'uuid', to: 'login#get_uuid'
      get 'qr', to: 'login#get_qr'
      get 'login', to: 'login#login'
      get 'tickets', to: 'login#get_tickets'
    end
  end

  namespace :admin do

  end
end
