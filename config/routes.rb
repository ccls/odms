ActionController::Routing::Routes.draw do |map|

	map.root :controller => :odms, :action => :show

	map.resources :subjects, :only => [:show,:index],
			:collection => { :dashboard => :get },
			:shallow => true do |subject|
#		subject.resource :patient
#		subject.resources :contacts, :only => :index
#		subject.resources :phone_numbers,		#	TEMP ADD DESTROY FOR DEV ONLY!
#			:only => [:new,:create,:edit,:update,   :destroy   ]
#		subject.resources :addressings,		#	TEMP ADD DESTROY FOR DEV ONLY!
#			:only => [:new,:create,:edit,:update,   :destroy   ]
#		subject.resources :enrollments,
#			:only => [:new,:create,:show,:edit,:update,:index]
#		subject.resources :events,
#			:only => [:index]
	end

	map.resources :bc_validations
	map.resources :birth_certificates
	map.resources :controls, :only => [:new,:show]
	map.resource  :case, :only => [:new]
	map.resource  :waivered, :only => [:new,:create]
	map.resource  :nonwaivered, :only => [:new,:create]

#	map.resources :projects
#	map.resources :guides
#	map.resources :document_versions

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
