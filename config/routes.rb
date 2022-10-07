Dradis::Plugins::Engine.routes.draw do
  resources :engines, only: [], param: :engine do
    member do
      put :enable
      put :disable
    end
  end
end
