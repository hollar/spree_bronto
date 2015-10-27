Spree::Core::Engine.routes.append do
  namespace :admin do
    resources :bronto_lists do
      collection do
         get 'get_lists'
      end
    end
  end

  resources :orders, :except => [:index, :new, :create, :destroy] do
    patch :subscribe, :on => :member
  end
end
