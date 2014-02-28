Instag::Application.routes.draw do
  resources :images
  root to: 'images#index'
  get "images/index"

end
