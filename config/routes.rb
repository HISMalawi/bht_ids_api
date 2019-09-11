Rails.application.routes.draw do
    # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  post '/api/v1/authenticate', to: 'authentication#authenticate'

  namespace :api do
    namespace :v1 do
      resources :users do      
        get '/users',           to: '/api/v1/users#index'
        get '/users/show',      to: '/api/v1/users#show'
        put '/users/update',    to: '/api/v1/users#update'
        delete '/users/destroy',    to: '/api/v1/users#destroy'
      end 

      post '/users/create',        to: '/api/v1/users#create'
      get '/reports/case_listing', to: '/api/v1/reports#cbs_case_listing'
      get '/reports/client_case_listing', to: '/api/v1/reports#cbs_client_case'
      get '/reports/art_initiated',   to: '/api/v1/reports#art_initiated'
      get '/locations/district_code', to: '/api/v1/locations#district_code'
      get '/locations/site_code',     to: '/api/v1/locations#site_code'
    end
  end
end

