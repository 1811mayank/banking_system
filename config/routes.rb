Rails.application.routes.draw do
  
  devise_for :users
  root 'welcome#index'
  resources :accounts
  resources :dashboard
  resources :loan, only: [:index, :new, :create]

  get 'confirm', to: "accounts#confirm"
  get 'details', to: "accounts#details"
  get 'balance', to: "accounts#balance"
  get 'transactions', to: "accounts#transactions"
  get 'transaction/:id', to: "accounts#transaction"
  get 'deposit', to: "accounts#deposit"
  get 'deposit/:id', to: "accounts#deposit_money"
  patch 'deposit/:id', to: "accounts#deposit_amount"
  get 'withdraw', to: "accounts#withdraw"
  get 'withdraw/:id', to: "accounts#withdraw_money"
  patch 'withdraw/:id', to: "accounts#withdraw_amount"
  get 'atmwithdraw/:id', to: "accounts#atmwithdraw"
  patch 'atmwithdraw/:id', to: "accounts#atmwithdraw_amount"
  get 'transfer', to: "accounts#transfer"
  get 'transfer/:id', to: "accounts#transfer_money"
  patch 'transfer/:id', to: "accounts#transfer_amount"
  get 'search_user', to: 'dashboard#search'
end
