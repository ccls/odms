# This used to be required in the application controller?
#require 'casclient'
#require 'casclient/frameworks/rails/filter'
class ApplicationController < ActionController::Base

	helper :all # include all helpers, all the time

	# See ActionController::RequestForgeryProtection for details
	protect_from_forgery 

	before_filter :get_guidance

	before_filter :login_required

	base_server_url = ( Rails.env == "production" ) ? 
		"https://auth.berkeley.edu" : 
		"https://auth-test.berkeley.edu"

	CASClient::Frameworks::Rails::Filter.configure(
		:username_session_key => :calnetuid,
		:cas_base_url => "#{base_server_url}/cas/"
	)

	helper_method :current_user, :logged_in?

protected	#	private #	(does it matter which or if neither?)

	def method_missing_with_authorization(symb,*args, &block)
		method_name = symb.to_s

		if method_name =~ /^may_(not_)?(.+)_required$/
			full_permission_name = "#{$1}#{$2}"
			negate = !!$1		#	double bang converts to boolean
			permission_name = $2
			verb,target = permission_name.split(/_/,2)

			#	using target words where singular == plural won't work here
			if !target.blank? && target == target.singularize
				unless permission = current_user.try(
						"may_#{permission_name}?", 
						instance_variable_get("@#{target}") 
					)
					message = "You don't have permission to " <<
						"#{verb} this #{target}."
				end
			else
				#	current_user may be nil so must use try and NOT send
				unless permission = current_user.try("may_#{permission_name}?")
					message = "You don't have permission to " <<
						"#{permission_name.gsub(/_/,' ')}."
				end
			end

			#	exclusive or
			unless negate ^ permission
				#	if message is nil, negate will be true
				message ||= "Access denied.  May #{(negate)?'not ':''}" <<
					"#{permission_name.gsub(/_/,' ')}."
				access_denied( message, (root_path||"/") )
			end
		else
			method_missing_without_authorization(symb, *args, &block)
		end
	end
	alias_method_chain :method_missing, :authorization

	def redirect_to_referer_or_default(default)
		redirect_to( session[:refer_to] || 
			request.env["HTTP_REFERER"] || default )
		session[:refer_to] = nil
	end

	#	Flash error message and redirect
	def access_denied( 
			message="You don't have permission to complete that action.", 
			default=root_path )
		session[:return_to] = request.url unless params[:format] == 'js'
		flash[:error] = message
		redirect_to default
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
		@guidance = Guide.where(:controller => params[:controller],
				:action => params[:action]).first
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
			#	irb(main):002:0> "asdf".to_date
			#	NoMethodError: undefined method `<' for nil:NilClass
			#		from /opt/local/lib/ruby/1.8/date.rb:621:in `valid_civil?'
			#		from /opt/local/lib/ruby/1.8/date.rb:751:in `new'
			#		from /opt/local/lib/ruby/gems/1.8/gems/activesupport-3.2.2/
			#			lib/active_support/core_ext/string/conversions.rb:45:in `to_date'
			#		from (irb):2
			end
		end

	end

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
		@current_user ||= if( session && session[:calnetuid] )
				#	if the user model hasn't been loaded yet
				#	this will return nil and fail.
				User.find_create_and_update_by_uid(session[:calnetuid])
			else
				nil
			end
	end

end
