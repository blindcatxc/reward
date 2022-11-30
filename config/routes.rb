Rails.application.routes.draw do
  resources :transactions, only: %w(create) do
    get :balance, on: :collection
    post :spend, on: :collection
  end
end
