Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  resources :posts
  root "posts#index"

=begin
  constraints Clearance::Constraints::SignedOut.new do
    root to: 'users#new'
  end

  constraints Clearance::Constraints::SignedIn.new do
    root to: 'posts#index', as: :signed_in_root
  end
=end
end
