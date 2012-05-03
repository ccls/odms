#	Abstracts controller to be used only as nested from StudySubject
class StudySubjectAbstractsController < ApplicationController

	layout 'subject'

	before_filter :append_current_user_to_params, :only => [:create,:merge]

	before_filter :may_create_abstracts_required,
		:only => [:new,:create,:compare,:merge]
	before_filter :may_read_abstracts_required,
		:only => [:index]
#		:only => [:show,:index]
#	before_filter :may_update_abstracts_required,
#		:only => [:edit,:update]
#	before_filter :may_destroy_abstracts_required,
#		:only => :destroy

#	before_filter :valid_id_required, 
#		:only => [:show,:edit,:update,:destroy]

	before_filter :valid_study_subject_id_required

	before_filter :case_study_subject_required,
		:only => [:new,:create,:compare,:merge]

	before_filter :two_abstracts_required, 
		:only => [:compare,:merge]

	before_filter :compare_abstracts,
		:only => [:compare,:merge]

	def index
		if !@study_subject.is_case?
			render :action => 'not_case' 
		else
			@abstracts = @study_subject.abstracts
		end
	end

	def new
#		@abstract = Abstract.new(params[:abstract])
		@abstract = @study_subject.abstracts.new(params[:abstract])
	end

	def create
		@abstract = @study_subject.abstracts.new(params[:abstract])
		@abstract.save!
		flash[:notice] = 'Success!'
		redirect_to @abstract
	rescue ActiveRecord::RecordNotSaved, ActiveRecord::RecordInvalid
		#	flash.now[:error] = "There was a problem creating the abstract"
		#	render :action => 'new'
		#	flash, not flash.now since redirecting and not rendering
		flash[:error] = "There was a problem creating the abstract"
		redirect_to study_subject_abstracts_path(@study_subject)
	end

#	def update
#		@abstract.update_attributes!(params[:abstract])
#		flash[:notice] = 'Success!'
#		redirect_to abstracts_path
#	rescue ActiveRecord::RecordNotSaved, ActiveRecord::RecordInvalid
#		flash.now[:error] = "There was a problem updating the abstract"
#		render :action => "edit"
#	end
#
#	def destroy
#		@abstract.destroy
#		redirect_to abstracts_path
#	end

	def compare
	end

	def merge
		@abstract = @study_subject.abstracts.new(params[:abstract].merge(:merging => true))
		@abstract.save!
		flash[:notice] = 'Success!'
		redirect_to @abstract
	rescue ActiveRecord::RecordNotSaved, ActiveRecord::RecordInvalid
		flash.now[:error] = "There was a problem merging the abstract"
		render :action => "compare"
	end

protected

	def compare_abstracts
		@abstracts = @study_subject.abstracts
		@diffs = @study_subject.abstract_diffs
	end

	def two_abstracts_required
		abstracts_count = @study_subject.abstracts_count
		unless( abstracts_count == 2 )
			access_denied("Must complete 2 abstracts before merging. " <<
				":#{abstracts_count}:")
		end
	end

	def append_current_user_to_params
		params[:abstract] = {} unless params[:abstract]
		params[:abstract].merge!(:current_user => current_user)
	end

#	def valid_id_required
#		if( !params[:id].blank? && Abstract.exists?(params[:id]) )
#			@abstract = Abstract.find(params[:id])
#			#	for id bar
#			@study_subject = @abstract.study_subject
#		else
#			access_denied("Valid id required!", abstracts_path)
#		end
#	end

	def case_study_subject_required
		unless( @study_subject.is_case? )
			access_denied("StudySubject must be Case to have abstract data!",
				@study_subject)
		end
	end

end
