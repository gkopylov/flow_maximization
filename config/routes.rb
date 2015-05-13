Rails.application.routes.draw do
  devise_for :users
  
  resources :users, :only => [:show] do
    resources :projects, :only => [:new, :create, :edit, :update, :destroy]
  end

  resources :projects do
    resources :nodes, :only => [:create, :update, :destroy] 

    resources :requests, :only => [:create, :edit, :update, :destroy] 

    get 'max_flow'

    get 'show_request_form'

    get 'start'
  end

  resources :connections, :only => [:create, :update, :destroy] do
    get 'delete_by_nodes', :on => :collection
  
    get 'find_by_nodes', :on => :collection
  end

  root :to => 'projects#index' 
end
