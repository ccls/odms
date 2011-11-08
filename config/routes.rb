ActionController::Routing::Routes.draw do |map|

	map.resources :locales, :only => :show

	map.root :controller => :odms, :action => :show

	map.resources :study_subjects, :only => [:edit,:update,:show,:index],
			:collection => { 
				:dashboard => :get,
				:find      => :get,
				:followup  => :get,
				:reports   => :get 
			},
			:shallow => true do |study_subject|
		study_subject.resource  :patient
		study_subject.resources :contacts, :only => :index
		study_subject.resources :phone_numbers,		#	TEMP ADD DESTROY FOR DEV ONLY!
			:only => [:new,:create,:edit,:update,   :destroy   ]
		study_subject.resources :addressings,		#	TEMP ADD DESTROY FOR DEV ONLY!
			:only => [:new,:create,:edit,:update,   :destroy   ]
		study_subject.resources :enrollments,
			:only => [:new,:create,:show,:edit,:update,:index]
		study_subject.resource  :consent,
			:only => [:show,:edit,:update]
		study_subject.resources :samples,
			:only => [:index]
		study_subject.resources :interviews,
			:only => [:index]
		study_subject.resources :events,
			:only => [:index]
		study_subject.resources :documents,
			:only => [:index]
		study_subject.resources :notes,
			:only => [:index]
	end

	map.resources :interviews, :only => [],
			:collection => { 
				:dashboard => :get,
				:find      => :get,
				:followup  => :get,
				:reports   => :get 
			}

	map.resources :samples, :only => [],
			:collection => { 
				:dashboard => :get,
				:find      => :get,
				:followup  => :get,
				:reports   => :get 
			}

	map.resources :studies, :only => [],
			:collection => { :dashboard => :get }

	map.resources :bc_requests, :only => [:new,:create,:edit,:update,:destroy,:index],
		:collection => { :confirm => :get },
		:member => { :update_status => :put }
	map.resources :bc_validations, :only => [:index, :show]
	map.resources :birth_certificates, :only => :index

	map.resources :candidate_controls, :only => [:edit,:update]

	map.resources :cases, :only => [:new,:create,:index,:show] do |c|
		#
		#	WARNING be careful as "case" is a ruby keyword!
		#
		c.resources :controls,   :only => [:new]	#,:create]
	end

	map.resource  :waivered, :only => [:new,:create]
	map.resource  :nonwaivered, :only => [:new,:create]

#	map.resources :projects
	map.resources :guides
#	map.resources :document_versions

	map.resources :pages, :collection => { 
		:all => :get,
#		:translate => :get,
		:order => :post }

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
