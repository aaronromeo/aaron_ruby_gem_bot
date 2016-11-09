Rails.application.routes.draw do
	resources :webhooks, only: [:index, :create]

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
