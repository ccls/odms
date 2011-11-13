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

	#	TODO stop using this if possible as isn't really clear.  (works though)
	#	should just extend the roles_controller(I think)
	#	and define the 'may_not_by_user_required' method.
	#
	#	This is a method that returns a hash containing
	#	permissions used in the before_filters as keys
	#	containing another hash with redirect_to and 
	#	message keys for special redirection.  By default,
	#	it will redirect to root_path on failure
	#	and the flash error will be a humanized
	#	version of the before_filter's name.
#	def redirections
#		@redirections ||= HashWithIndifferentAccess.new({
#			:not_be_user => {
#				:redirect_to => user_path(current_user)
#			}
#		})
#	end

	#	used in roles_controller
	def may_not_be_user_required
		current_user.may_not_be_user?(@user) || access_denied(
			"You may not be this user to do this", user_path(current_user))
	end

#	This is tricky with the multi-negatives.
#	def may_not_be_user_required
##		current_user.may_not_be_user?(current_user) ||	#	should've been (@user)
#		current_user.may_be_user?(current_user) &&	#	should've been (@user)
#			access_denied("May not be user required.", user_path(current_user) )
#	end

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
		return if params[:format] == 'js'	#	better
		require 'guide'
		@guidance = Guide.find(:first, :conditions => {
				:controller => self.class.name.underscore.sub(/_controller/,''),
				:action => params[:action] }) ||
			Guide.find(:first, :conditions => {
				:controller => self.class.name.underscore })
	end

	def common_raf_create(study_subject_params)
		@study_subject = StudySubject.new(study_subject_params)

		#	explicitly validate before searching for duplicates
		raise ActiveRecord::RecordInvalid.new(@study_subject) unless @study_subject.valid?

		warn = []
		#	regular create submit	#	tests DO NOT SEND params[:commit] = 'Submit'
		if params[:commit].blank? or params[:commit] == 'Submit'
			@duplicates = @study_subject.duplicates
			raise StudySubject::DuplicatesFound unless @duplicates.empty?
		end

		if params[:commit] == 'Match Found'
			@duplicates = @study_subject.duplicates
			if params[:duplicate_id] and
					( duplicate = StudySubject.find_by_id(params[:duplicate_id]) ) and
					@duplicates.include?(duplicate)
				duplicate.raf_duplicate_creation_attempted(@study_subject)
				flash[:notice] = "Operational Event created marking this attempted entry."
				redirect_to duplicate
			else
				#
				#	Match Found, but no duplicate_id or subject with the id
				#
				warn << "No valid duplicate_id given"
				raise StudySubject::DuplicatesFound unless @duplicates.empty?
			end

		#	params[:commit].blank? or params[:commit] == 'Submit' 
		#		or params[:commit] == 'No Match'
		else 
			#	No duplicates found or if there were, not matches.
			#	Transactions are only for marking a rollback point.
			#	The raised error will still kick all the way out.
			StudySubject.transaction do
				@study_subject.save!
				@study_subject.assign_icf_master_id
				@study_subject.create_mother
			end

			if @study_subject.identifier.icf_master_id.blank?
				warn << "Case was not assigned an icf_master_id."
			end
			if @study_subject.mother.identifier.icf_master_id.blank?
				warn << "Mother was not assigned an icf_master_id."
			end
			flash[:warn] = warn.join('<br/>') unless warn.empty?
			redirect_to @study_subject
		end
	rescue ActiveRecord::RecordNotSaved, ActiveRecord::RecordInvalid
		flash.now[:error] = "StudySubject creation failed"
		render :action => 'new'
	rescue ActiveRecord::StatementInvalid => e
		flash.now[:error] = "Database error.  Check production logs and contact Jake."
		render :action => 'new'
	rescue StudySubject::DuplicatesFound
		flash.now[:error] = "Possible Duplicate(s) Found."
		flash.now[:warn] = warn.join('<br/>') unless warn.empty?
		render :action => 'new'
	end

end
