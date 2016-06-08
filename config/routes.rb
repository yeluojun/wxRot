Rails.application.routes.draw do
  root 'index#index'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  namespace :api do
    namespace :v1 do
      get 'uuid', to: 'login#get_uuid'
      get 'qt', to: 'login#get_qr'
      get 'login', to: 'login#login'
    end
  end
end
