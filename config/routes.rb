# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html
# get 'delivery_project', :to => 'delivery_project#index'
# post 'post/:id/update', :to => 'delivery_project#update'

resources :calendar_project do 

	post 'update_delivery_date', :on => :collection
	post 'delete_event', :on => :collection
	post 'save_or_update_title', :on => :collection
	
end
