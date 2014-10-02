Dinmo::Application.routes.draw do
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  devise_for :users, :controllers => {:registrations => 'registrations'}
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'static_pages#home'

  resources :after_signup
  resources :users do
    member do
      put :available
      put :unavailable
    end
  end
  resources :conversations
  resources :messages

  get 'events' => 'conversations#events'
  get 'twilio/process_sms' => 'conversations#process_sms'
  match '/terms',           to:     'static_pages#terms',        via: 'get'

  get 'tutorial'   => 'tutorial#step1'
  get 'tutorial-2' => 'tutorial#step2'
  get 'tutorial-3' => 'tutorial#step3'
  get 'tutorial-4' => 'tutorial#step4'

end
