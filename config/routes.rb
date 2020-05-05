Rails.application.routes.draw do
  get 'ratings/index'

  get 'ratings/show'

  get 'ratings/new'
  post 'ratings/new'

  get 'ratings/edit'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  namespace :api do
    resources :trucks, only: [:show, :index, :update] do
      resources :ratings, only: [:create]
    end
  end

  resources :tags, only: [:index, :show]

  root "trucks#index" # tells rails to map request to the root fo the application to the controller's (trucks) index action and get 'trucks/index'

end
