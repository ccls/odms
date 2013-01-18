Odms::Application.routes.draw do

	#	rather than try to get multiple route files working,
	#	just conditionally add this testing route.
	if Rails.env == 'test'
		resource :fake_session, :only => [:new,:create]
	end

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


#
#
#		http://yehudakatz.com/2009/12/26/the-rails-3-router-rack-it-up/
#
#		http://guides.rubyonrails.org/routing.html
#
#

	root :to => 'odms#show'

	resources :address_types
	resources :bc_requests, :except => :show do
		collection { get :confirm }
		member     { put :update_status }
	end
	resources :birth_data, :except => [:new,:create]
	resources :birth_datum_updates, :except => [:edit,:update]
	resources :candidate_controls, :only => [:edit,:update,:index,:show]
	#	Removing RAF forms and creating a single RAF-like form
	#	for cases only and adding edit/update/show.
#	resources :cases, :only => [:new,:create,:edit,:update,:show,:index] do
#	resources :cases, :only => [:index] do
#		#
#		#	WARNING be careful as "case" is a ruby keyword!
#		#
#		resources :controls,   :only => [:new]	#,:create]
#	end

	resources :cases, :only => [:index] do
		collection { put :assign_selected_for_interview }
	end

	resources :controls, :only => [:new,:create,:index]
	resources :contexts
	resources :data_sources
	resources :diagnoses
	resources :document_types
	resources :document_versions
	resources :follow_up_types
	resources :guides
	resources :hospitals
	resources :icf_master_ids, :only => [:index,:show]
#	resources :icf_master_trackers, :only => [:index,:show,:update]
#	resources :icf_master_tracker_updates do 
#		member { post :parse }
#	end
	resources :instrument_types
	resources :instrument_versions
	resources :ineligible_reasons
	resources :instruments
	resources :interview_methods
	resources :interview_outcomes
	resources :languages
	resources :locales, :only => :show
	resources :odms_exceptions, :except => [:new,:create]
	resources :operational_event_types do
		collection { get 'options' }
	end
	resources :organizations
	resources :pages do
		collection do
			get  :all
			post :order
		end
	end
	resources :people
	resources :phone_types
	resources :project_outcomes
	resources :projects
	resources :rafs, :only => [:new,:create,:edit,:update,:show]
	resources :races
	resource  :receive_sample, :only => [:new,:create]
	resources :refusal_reasons
	resources :sample_formats
	resources :sample_locations
	resources :sample_outcomes
	resources :sample_temperatures
	resources :sample_transfers, :only => :index do
		collection { put :confirm }
		member     { put :update_status }
	end
	resources :sample_types

#	resources :screening_data, :except => [:new,:create]
#	resources :screening_datum_updates, :except => [:edit,:update]
	resources :sections
	resources :subject_relationships
	resources :subject_types
	resources :tracing_statuses
	resources :units
	resources :vital_statuses
	resources :zip_codes, :only => [ :index ]

	match 'logout', :to => 'sessions#destroy'

	resources :users, :only => [:destroy,:show,:index] do
		resources :roles, :only => [:update,:destroy]
	end
	resource :session, :only => [ :destroy ]

	#	Route declaration order matters.
	#	This MUST be BEFORE the declaration of
	#	 study_subject.resources :samples
	#	or 'dashboard' will be treated as a sample id.
	resources :samples, :only => [] do
		collection do
			get :dashboard
			get :find
			get :followup
			get :reports
			get :manifest
		end
	end

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

	#	I think that these MUST come before the study subject sub routes
	resources :abstracts, :except => [:new,:create] do
		#	specify custom location controllers to avoid conflict
		#	with app controllers ( just diagnoses now )
		resource :identifying_datum, :only => [:edit,:update,:show],
			:controller => 'abstract/identifying_data'
		resource :bone_marrow, :only => [:edit,:update,:show],
			:controller => 'abstract/bone_marrows'
		resource :cbc, :only => [:edit,:update,:show],
			:controller => 'abstract/cbcs'
		resource :cerebrospinal_fluid, :only => [:edit,:update,:show],
			:controller => 'abstract/cerebrospinal_fluids'
		resource :checklist, :only => [:edit,:update,:show],
			:controller => 'abstract/checklists'
		resource :chest_imaging, :only => [:edit,:update,:show],
			:controller => 'abstract/chest_imagings'
		resource :clinical_chemo_protocol, :only => [:edit,:update,:show],
			:controller => 'abstract/clinical_chemo_protocols'
		resource :cytogenetic, :only => [:edit,:update,:show],
			:controller => 'abstract/cytogenetics'
		resource :diagnosis, :only => [:edit,:update,:show],
			:controller => 'abstract/diagnoses'
		resource :discharge, :only => [:edit,:update,:show],
			:controller => 'abstract/discharges'
		resource :flow_cytometry, :only => [:edit,:update,:show],
			:controller => 'abstract/flow_cytometries'
		resource :histocompatibility, :only => [:edit,:update,:show],
			:controller => 'abstract/histocompatibilities'
		resource :name, :only => [:edit,:update,:show],
			:controller => 'abstract/names'
		resource :tdt, :only => [:edit,:update,:show],
			:controller => 'abstract/tdts'
		resource :therapy_response, :only => [:edit,:update,:show],
			:controller => 'abstract/therapy_responses'
	end

#	resources :study_subjects, :only => [:edit,:update,:show,:index],
#			:shallow => true do 
	resources :study_subjects, :only => [:edit,:update,:show,:index] do
		member do
			get :next
			get :prev
		end
		collection do
			get :first
			get :last
			get :by
			get :dashboard
			get :find
			get :followup
			get :reports
		end
		resource  :patient
		resource  :birth_record, :only => :show
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

		#
		#	Add index action and set custom controller name
		#
		resources :abstracts, :only => [:new,:create,:index],
			:controller => 'study_subject_abstracts' do
			collection do
				get  :compare
				post :merge
			end
		end
		resources :related_subjects, :only => [:index]
	end

	#	format seems to be required in the url? UNLESS wrapped in ()!
#	match 'study_subject_reports/:action(.:format)' => 'study_subject_reports'
	match 'charts/:action.:format' => 'charts'

	namespace :sunspot do
		resources :subjects, :only => :index
	end

#	namespace :api do
#		resources :study_subjects, :only => :index
#		resources :patients,       :only => :index
#		resources :projects,       :only => :index
#		resources :enrollments,    :only => :index
#		resources :addresses,      :only => :index
#		resources :addressings,    :only => :index
#		resources :phone_numbers,  :only => :index
#	end

	#	Create named routes for expected pages so can avoid
	# needing to append the relative_url_root prefix manually.
	#	ActionController::Base.relative_url_root + '/admin',
#	with_options :controller => "pages", :action => "show" do |page|
#		page.admin   '/admin',   :path => ["admin"]
#		page.faqs    '/faqs',    :path => ["faqs"]
#		page.reports '/reports', :path => ["reports"]
#	end

#	TODO can't seem to duplicate the above.  Boo.

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
