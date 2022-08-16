Rails.application.routes.draw do
  
  devise_for :users

  root 'welcome#index'

  resource :users , only: [:show]

  resources :accounts do
    get 'confirm', on: :collection
    get 'balance', on: :collection
  end

  resources :admin, only: [:index]

  resources :loan, only: [:index, :new, :create]
  
  resources :transactions

  # deposit
  get 'deposit', to: "transactions#deposit"
  get 'deposit/:id', to: "transactions#deposit_money"
  patch 'deposit/:id', to: "transactions#deposit_amount"

  # withdrawal
  get 'withdraw', to: "transactions#withdraw"
  get 'withdraw/:id', to: "transactions#withdraw_money"
  patch 'withdraw/:id', to: "transactions#withdraw_amount"

  # Atm withdrawal 
  get 'atmwithdraw/:id', to: "transactions#atmwithdraw"
  patch 'atmwithdraw/:id', to: "transactions#atmwithdraw_amount"

  # money transfer
  get 'transfer', to: "transactions#transfer"
  get 'transfer/:id', to: "transactions#transfer_money"
  patch 'transfer/:id', to: "transactions#transfer_amount"

  # search user in admin  
  get 'search_user', to: 'admin#search'

  # api collection
  namespace :api do
    mount_devise_token_auth_for 'User', at: 'auth', controllers:{
      sessions: 'api/sessions'
    }
    defaults format: :json do

      resources :user, only: [:index]
      post 'accounts', to: "accounts#create"
      get 'details', to: "user#details"
      get 'balance', to: "accounts#balance"
      get 'transactions', to: "transactions#transactions"
      post 'deposit', to: "transactions#deposit"
      post 'withdraw', to: "accounts#withdraw"
      post 'transfer', to: "accounts#transfer"
      post 'loan', to: "loan#loan"
      post 'atmwithdraw', to: "accounts#atmwithdraw"
    end
  end
   

end
