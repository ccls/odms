class ApplicationController < ActionController::Base

	helper :all # include all helpers, all the time

	# See ActionController::RequestForgeryProtection for details
	protect_from_forgery 

	before_filter :get_guidance

protected	#	private #	(does it matter which or if neither?)

	def ssl_allowed?
		#	Gary has setup the genepi server to force https with its own redirection.
		#	Forcing ssl in the application results in about 20 redirections back
		#	to itself, so this tells the app to ignore it.
		#	For testing, we cannot ignore the action check.
		#	I could use an alias_method_chain here, but would actually take more lines.
		request.host == "odms.brg.berkeley.edu" || (
			self.class.read_inheritable_attribute(:ssl_allowed_actions) || []).include?(action_name.to_sym)
#true
	end

	#	used in roles_controller
	def may_not_be_user_required
		current_user.may_not_be_user?(@user) || access_denied(
			"You may not be this user to do this", user_path(current_user))
	end

	def valid_study_subject_id_required
		if !params[:study_subject_id].blank? and StudySubject.exists?(params[:study_subject_id])
			@study_subject = StudySubject.find(params[:study_subject_id])
		else
			access_denied("Valid study_subject id required!", study_subjects_path)
		end
	end

#	def block_all_access
#		access_denied("That route is no longer available")
#	end
#
#	def valid_hx_study_subject_id_required
#		validate_hx_study_subject_id(params[:study_subject_id])
#	end
#
#	def valid_id_for_hx_study_subject_required
#		validate_hx_study_subject_id(params[:id])
#	end
#
#	#	I intended to check that the study_subject is actually
#	#	enrolled in HomeExposures, but haven't yet.
#	def validate_hx_study_subject_id(id,redirect=nil)
#		if !id.blank? and StudySubject.exists?(id)
#			@study_subject = StudySubject.find(id)
#		else
#			access_denied("Valid study_subject id required!", 
#				redirect || study_subjects_path)
#		end
#	end

#	Don't know if I'll use this or not.
#
#	def get_hx_study_subjects
#		hx = Project['HomeExposures']
#		if params[:commit] && params[:commit] == 'download'
#			params[:paginate] = false
#		end
#		#   params[:projects] ||= {}
#		#   params[:projects][hx.id] ||= {}
#		#   @study_subjects = StudySubject.search(params)
#		@study_subjects = hx.study_subjects.search(params)
#	end

	def record_or_recall_sort_order
		%w( dir order ).map(&:to_sym).each do |param|
			if params[param].blank? && !session[param].blank?
				params[param] = session[param]	#	recall
			elsif !params[param].blank?
				session[param] = params[param]	#	record
			end
		end
	end
	alias_method :recall_or_record_sort_order, :record_or_recall_sort_order

	def get_guidance
		return unless [nil,'html'].include?(params[:format])
		require_dependency 'guide.rb' unless Guide
		@guidance = Guide.find(:first, :conditions => {
				:controller => params[:controller],
				:action => params[:action] })
	end


	#	used by study_subjects/find and samples/find
	#	As 'page' is on the form, it could be blank.
	#	This can result in ...
	#	"" given as value, which translates to '0' as page number
	def valid_find_page
		( !params[:page].blank? && ( params[:page].to_i > 0 ) ) ? params[:page] : 1
	end

	#	used by study_subjects/find and samples/find
	def valid_find_operator
		operator = ' OR '
		if params[:operator] and !params[:operator].blank? and 
				['AND','OR'].include?(params[:operator])
			operator = " #{params[:operator]} "
		end
		operator
	end

	#	this one's a bit touchy.
	#	key is the params key and conditions is the [[],{}]
	#	for passing to find.
	def validate_valid_date_range_for(key,conditions)
		if params[key] and !params[key].blank?
			begin
				#	ensure correct format. Could raise error if parser fails so do first.
				valid_date = params[key].to_date	
				conditions[1]["#{key}_1".to_sym] = valid_date - 1.day
				conditions[1]["#{key}_2".to_sym] = valid_date + 1.day
				conditions[0] << "( #{key} BETWEEN :#{key}_1 AND :#{key}_2 )"
			rescue
#	probably a poorly formatted date.
#	>> 'asdf'.to_date
#NoMethodError: undefined method `<' for nil:NilClass
#	from /Library/Ruby/Gems/1.8/gems/activesupport-2.3.14/lib/active_support/whiny_nil.rb:52:in `method_missing'
#	from /System/Library/Frameworks/Ruby.framework/Versions/1.8/usr/lib/ruby/1.8/date.rb:621:in `valid_civil?'
#	from /System/Library/Frameworks/Ruby.framework/Versions/1.8/usr/lib/ruby/1.8/date.rb:751:in `new'
#	from /Library/Ruby/Gems/1.8/gems/activesupport-2.3.14/lib/active_support/core_ext/string/conversions.rb:19:in `to_date'
#	from (irb):2
			end
		end

	end

#	def valid_find_date
#		if params[:dob] and !params[:dob].blank?
#			begin
#				#	ensure correct format. Could raise error if parser fails so do first.
#				valid_date = params[:dob].to_date	
#				conditions[1][:dob] = valid_date
#				conditions[0] << "( dob = :dob )"
#			rescue
##	probably a poorly formatted date.
##	>> 'asdf'.to_date
##NoMethodError: undefined method `<' for nil:NilClass
##	from /Library/Ruby/Gems/1.8/gems/activesupport-2.3.14/lib/active_support/whiny_nil.rb:52:in `method_missing'
##	from /System/Library/Frameworks/Ruby.framework/Versions/1.8/usr/lib/ruby/1.8/date.rb:621:in `valid_civil?'
##	from /System/Library/Frameworks/Ruby.framework/Versions/1.8/usr/lib/ruby/1.8/date.rb:751:in `new'
##	from /Library/Ruby/Gems/1.8/gems/activesupport-2.3.14/lib/active_support/core_ext/string/conversions.rb:19:in `to_date'
##	from (irb):2
#			end
#		end
#	end


before_filter :login_required

		base_server_url = ( RAILS_ENV == "production" ) ? 
			"https://auth.berkeley.edu" : 
			"https://auth-test.berkeley.edu"

		CASClient::Frameworks::Rails::Filter.configure(
			:username_session_key => :calnetuid,
			:cas_base_url => "#{base_server_url}/cas/"
		)

		helper_method :current_user, :logged_in?


		def logged_in?
			!current_user.nil?
		end

		#	Force the user to be have an SSO session open.
		def current_user_required
			# Have to add ".filter(self)" when not in before_filter line.
			CASClient::Frameworks::Rails::Filter.filter(self)
		end
		alias_method :login_required, :current_user_required

		def current_user
			load 'user.rb' unless defined?(User)
			@current_user ||= if( session && session[:calnetuid] )
					#	if the user model hasn't been loaded yet
					#	this will return nil and fail.
					User.find_create_and_update_by_uid(session[:calnetuid])
				else
					nil
				end
		end


end
