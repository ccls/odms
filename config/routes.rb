Odms::Application.routes.draw do
	# The priority is based upon order of creation:
	# first created -> highest priority.

	# Sample of regular route:
	#   match 'products/:id' => 'catalog#view'
	# Keep in mind you can assign values other than :controller and :action

	# Sample of named route:
	#   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
	# This route can be invoked with purchase_url(:id => product.id)

	# Sample resource route (maps HTTP verbs to controller actions automatically):
	#   resources :products

	# Sample resource route with options:
	#   resources :products do
	#     member do
	#       get 'short'
	#       post 'toggle'
	#     end
	#
	#     collection do
	#       get 'sold'
	#     end
	#   end

	# Sample resource route with sub-resources:
	#   resources :products do
	#     resources :comments, :sales
	#     resource :seller
	#   end

	# Sample resource route with more complex sub-resources
	#   resources :products do
	#     resources :comments
	#     resources :sales do
	#       get 'recent', :on => :collection
	#     end
	#   end

	# Sample resource route within a namespace:
	#   namespace :admin do
	#     # Directs /admin/products/* to Admin::ProductsController
	#     # (app/controllers/admin/products_controller.rb)
	#     resources :products
	#   end

	# You can have the root of your site routed with "root"
	# just remember to delete public/index.html.
	# root :to => 'welcome#index'

	# See how all your routes lay out with "rake routes"

	# This is a legacy wild controller route that's not recommended for RESTful applications.
	# Note: This route will make all actions in every controller accessible via GET requests.
	# match ':controller(/:action(/:id))(.:format)'

#end
#__END__
#ActionController::Routing::Routes.draw do |map|

	namespace :active_scaffold do
		with_options :active_scaffold => true do |as|
	  	as.resources :study_subjects
	  	as.resources :subject_races
	  	as.resources :subject_languages
	  	as.resources :patients
	  	as.resources :addresses
	  	as.resources :addressings
	  	as.resources :phone_numbers
	  	as.resources :enrollments
	  	as.resources :data_sources
		end
	end




#
#
#		http://yehudakatz.com/2009/12/26/the-rails-3-router-rack-it-up/
#
#



#	TODO	don't know if this is right
#	logout 'logout', :controller => 'sessions', :action => 'destroy'
#	controller :sessions do
#		delete 'logout' => :destroy
#	end
	match 'logout', :to => 'sessions#destroy'


	resources :users, :only => [:destroy,:show,:index] do
		resources :roles, :only => [:update,:destroy]
	end
	resource :session, :only => [ :destroy ]

	resources :races
	resources :languages
	resources :people
	resources :refusal_reasons
	resources :ineligible_reasons
	resources :zip_codes, :only => [ :index ]
	resources :operational_event_types, :only => [] do
		collection { get 'options' }
	end
#	resources :operational_event_types, :only => [],
#		:collection => { :options => :get }

	resources :locales, :only => :show

#	root :controller => :odms, :action => :show
	root :to => 'odms#show'

	#	Route declaration order matters.
	#	This MUST be BEFORE the declaration of
	#	 study_subject.resources :samples
	#	or 'dashboard' will be treated as a sample id.
#	resources :samples, :only => [],
#			:collection => { 
#				:dashboard => :get,
#				:find      => :get,
#				:followup  => :get,
#				:reports   => :get 
#			}
	resources :samples, :only => [] do
		collection do
			get :dashboard
			get :find
			get :followup
			get :reports
		end
	end

#	resources :interviews, :only => [],
#			:collection => { 
#				:dashboard => :get,
#				:find      => :get,
#				:followup  => :get,
#				:reports   => :get 
#			}
	resources :interviews, :only => [] do
		collection do
			get :dashboard
			get :find
			get :followup
			get :reports
		end
	end

	resources :studies, :only => [] do
		collection { get :dashboard }
	end

	resource :receive_sample, :only => [:new,:create]

#	resources :study_subjects, :only => [:edit,:update,:show,:index],
#			:collection => { 
#				:dashboard => :get,
#				:find      => :get,
#				:followup  => :get,
#				:reports   => :get 
#			},
#			:shallow => true do 
	resources :study_subjects, :only => [:edit,:update,:show,:index],
			:shallow => true do 
		collection do
			get :dashboard
			get :find
			get :followup
			get :reports
		end
		resource  :patient
		#	TEMP ADD DESTROY FOR DEV OF PHONE AND ADDRESS ONLY!
		resources :phone_numbers, :except => [:index,:show]
		resources :addressings,   :except => [:index,:show]
		resources :enrollments,   :except => :destroy
		resource  :consent,
			:only => [:show,:edit,:update]
		resources :samples
		resources :events
		resources :contacts,   :only => :index
		resources :interviews, :only => :index
		resources :documents,  :only => :index
		resources :notes,      :only => :index
	end

#	resources :bc_requests, :only => [:new,:create,:edit,:update,:destroy,:index],
	resources :bc_requests, :except => :show do
		collection { get :confirm }
		member     { put :update_status }
	end

	#	These are currently not used
	#	resources :bc_validations, :only => [:index, :show]
	#	resources :birth_certificates, :only => :index

	resources :candidate_controls, :only => [:edit,:update]

	resources :related_subjects, :only => [:show]

	resources :cases, :only => [:new,:create,:index] do
		#
		#	WARNING be careful as "case" is a ruby keyword!
		#
		resources :controls,   :only => [:new]	#,:create]
	end

	resource  :waivered,    :only => [:new,:create]
	resource  :nonwaivered, :only => [:new,:create]

	resources :projects
	resources :guides
	resources :document_versions
	resources :icf_master_trackers, :only => [:index,:show,:update]
	resources :icf_master_tracker_updates do 
		member { post :parse }
	end
	resources :live_birth_data_updates do 
		member { post :parse }
	end

	resources :pages do
		collection do
			get  :all
			post :order
		end
	end

#	TODO don't know if this is right either
#	connect 'charts/:action.:format', :controller => 'charts'
#	match 'charts(/:action(/:id))(.:format)'
	match 'charts/:action.:format' => 'charts'

	namespace :api do
		resources :study_subjects, :only => :index
		resources :patients,       :only => :index
		resources :projects,       :only => :index
		resources :enrollments,    :only => :index
		resources :addresses,      :only => :index
		resources :addressings,    :only => :index
		resources :phone_numbers,  :only => :index
	end

	#	Create named routes for expected pages so can avoid
	# needing to append the relative_url_root prefix manually.
	#	ActionController::Base.relative_url_root + '/admin',
#	with_options :controller => "pages", :action => "show" do |page|
#		page.admin   '/admin',   :path => ["admin"]
#		page.faqs    '/faqs',    :path => ["faqs"]
#		page.reports '/reports', :path => ["reports"]
#	end


	#	TODO don't think this is quite right
#	match 'admin'   => 'pages#show', :as => 'admin', :path => ["admin"]
#	match 'admin', :to => 'pages#show', :as => 'admin'
#	match '*path', :to => 'pages', :as => 'admin'
##	match 'admin', :to => { :controller => :pages, :action => :show, :path => ["admin"] }, :as => 'admin'
#	match 'faqs'    => 'pages', :as => 'faqs'
#	match 'reports' => 'pages', :as => 'reports'

#	controller :pages


	#	MUST BE LAST OR WILL BLOCK ALL OTHER ROUTES!
	#	catch all route to manage admin created pages.
#	connect   '*path', :controller => 'pages', :action => 'show'
	#	TODO don't know if this is right either
	get '*path' => 'pages#show'

end


__END__

ActionController::Routing::Routes.draw do |map|

	map.namespace :active_scaffold do |n|
#	  n.resources :study_subjects, :active_scaffold => true
#	  n.resources :subject_races, :active_scaffold => true
#	  n.resources :subject_languages, :active_scaffold => true
#	  n.resources :patients, :active_scaffold => true
#	  n.resources :addresses, :active_scaffold => true
#	  n.resources :addressings, :active_scaffold => true
#	  n.resources :phone_numbers, :active_scaffold => true
#	  n.resources :enrollments, :active_scaffold => true
#	  n.resources :data_sources, :active_scaffold => true
		n.with_options :active_scaffold => true do |as|
	  	as.resources :study_subjects
	  	as.resources :subject_races
	  	as.resources :subject_languages
	  	as.resources :patients
	  	as.resources :addresses
	  	as.resources :addressings
	  	as.resources :phone_numbers
	  	as.resources :enrollments
	  	as.resources :data_sources
		end
	end

	map.logout 'logout', :controller => 'sessions', :action => 'destroy'
	map.resources :users, :only => [:destroy,:show,:index] do |user|
		user.resources :roles, :only => [:update,:destroy]
	end
	map.resource :session, :only => [ :destroy ]

	map.resources :races
	map.resources :languages
	map.resources :people
	map.resources :refusal_reasons
	map.resources :ineligible_reasons
	map.resources :zip_codes, :only => [ :index ]
	map.resources :operational_event_types, :only => [],
		:collection => { :options => :get }

	map.resources :locales, :only => :show

	map.root :controller => :odms, :action => :show

	#	Route declaration order matters.
	#	This MUST be BEFORE the declaration of
	#	 study_subject.resources :samples
	#	or 'dashboard' will be treated as a sample id.
	map.resources :samples, :only => [],
			:collection => { 
				:dashboard => :get,
				:find      => :get,
				:followup  => :get,
				:reports   => :get 
			}

	map.resources :interviews, :only => [],
			:collection => { 
				:dashboard => :get,
				:find      => :get,
				:followup  => :get,
				:reports   => :get 
			}

	map.resources :studies, :only => [],
			:collection => { :dashboard => :get }

	map.resource :receive_sample, :only => [:new,:create]

	map.resources :study_subjects, :only => [:edit,:update,:show,:index],
			:collection => { 
				:dashboard => :get,
				:find      => :get,
				:followup  => :get,
				:reports   => :get 
			},
			:shallow => true do |study_subject|
		study_subject.resource  :patient
		#	TEMP ADD DESTROY FOR DEV OF PHONE AND ADDRESS ONLY!
		study_subject.resources :phone_numbers, :except => [:index,:show]
		study_subject.resources :addressings,   :except => [:index,:show]
		study_subject.resources :enrollments,   :except => :destroy
		study_subject.resource  :consent,
			:only => [:show,:edit,:update]
		study_subject.resources :samples
		study_subject.resources :events
		study_subject.resources :contacts,   :only => :index
		study_subject.resources :interviews, :only => :index
		study_subject.resources :documents,  :only => :index
		study_subject.resources :notes,      :only => :index
	end

#	map.resources :bc_requests, :only => [:new,:create,:edit,:update,:destroy,:index],
	map.resources :bc_requests, :except => :show,
		:collection => { :confirm => :get },
		:member => { :update_status => :put }

	#	These are currently not used
	#	map.resources :bc_validations, :only => [:index, :show]
	#	map.resources :birth_certificates, :only => :index

	map.resources :candidate_controls, :only => [:edit,:update]

	map.resources :related_subjects, :only => [:show]

	map.resources :cases, :only => [:new,:create,:index] do |c|
		#
		#	WARNING be careful as "case" is a ruby keyword!
		#
		c.resources :controls,   :only => [:new]	#,:create]
	end

	map.resource  :waivered,    :only => [:new,:create]
	map.resource  :nonwaivered, :only => [:new,:create]

	map.resources :projects
	map.resources :guides
	map.resources :document_versions
	map.resources :icf_master_trackers, :only => [:index,:show,:update]
	map.resources :icf_master_tracker_updates, :member => {
		:parse => :post
	}
	map.resources :live_birth_data_updates, :member => {
		:parse => :post
	}

	map.resources :pages, :collection => { 
		:all => :get,
		:order => :post }

	map.connect 'charts/:action.:format', :controller => 'charts'

	map.namespace :api do |api|
		api.resources :study_subjects, :only => :index
		api.resources :patients,       :only => :index
		api.resources :projects,       :only => :index
		api.resources :enrollments,    :only => :index
		api.resources :addresses,      :only => :index
		api.resources :addressings,    :only => :index
		api.resources :phone_numbers,  :only => :index
	end

	#	Create named routes for expected pages so can avoid
	# needing to append the relative_url_root prefix manually.
	#	ActionController::Base.relative_url_root + '/admin',
	map.with_options :controller => "pages", :action => "show" do |page|
		page.admin   '/admin',   :path => ["admin"]
		page.faqs    '/faqs',    :path => ["faqs"]
		page.reports '/reports', :path => ["reports"]
	end
	#	MUST BE LAST OR WILL BLOCK ALL OTHER ROUTES!
	#	catch all route to manage admin created pages.
	map.connect   '*path', :controller => 'pages', :action => 'show'

end
