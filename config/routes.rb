Rails.application.routes.draw do
    # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  post 'authenticate', to: 'authentication#authenticate'
  namespace :api do
    namespace :v1 do
      post '/reports/case_listing', to: '/api/v1/reports#cbs_case_listing'
    end
  end
end
