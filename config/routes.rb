Rails.application.routes.draw do
  get 'social_networks/index'
  root "social_networks#index"
end
