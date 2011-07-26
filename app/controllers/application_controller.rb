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
	end

#	TODO stop using this if possible
	#	This is a method that returns a hash containing
	#	permissions used in the before_filters as keys
	#	containing another hash with redirect_to and 
	#	message keys for special redirection.  By default,
	#	it will redirect to root_path on failure
	#	and the flash error will be a humanized
	#	version of the before_filter's name.
	def redirections
		@redirections ||= HashWithIndifferentAccess.new({
			:not_be_user => {
				:redirect_to => user_path(current_user)
			}
		})
	end

	def valid_subject_id_required
		if !params[:subject_id].blank? and Subject.exists?(params[:subject_id])
			@subject = Subject.find(params[:subject_id])
		else
			access_denied("Valid subject id required!", subjects_path)
		end
	end


#	def block_all_access
#		access_denied("That route is no longer available")
#	end
#
#	def valid_hx_subject_id_required
#		validate_hx_subject_id(params[:subject_id])
#	end
#
#	def valid_id_for_hx_subject_required
#		validate_hx_subject_id(params[:id])
#	end
#
#	#	I intended to check that the subject is actually
#	#	enrolled in HomeExposures, but haven't yet.
#	def validate_hx_subject_id(id,redirect=nil)
#		if !id.blank? and Subject.exists?(id)
#			@subject = Subject.find(id)
#		else
#			access_denied("Valid subject id required!", 
#				redirect || subjects_path)
#		end
#	end

#	Don't know if I'll use this or not.
#
#	def get_hx_subjects
#		hx = Project['HomeExposures']
#		if params[:commit] && params[:commit] == 'download'
#			params[:paginate] = false
#		end
#		#   params[:projects] ||= {}
#		#   params[:projects][hx.id] ||= {}
#		#   @subjects = Subject.search(params)
#		@subjects = hx.subjects.search(params)
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
		return if params[:format] == 'js'	#	better
#		return if [ "/users/menu.js" ].include?(request.env['REQUEST_PATH'])
		require 'guide'
		@guidance = Guide.find(:first, :conditions => {
				:controller => self.class.name.underscore.sub(/_controller/,''),
				:action => params[:action] }) ||
			Guide.find(:first, :conditions => {
				:controller => self.class.name.underscore })
	end

end
