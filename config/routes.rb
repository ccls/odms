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
