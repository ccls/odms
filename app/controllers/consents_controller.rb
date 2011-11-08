class ConsentsController < ApplicationController

#	before_filter :may_create_consents_required,
#		:only => [:new,:create]
	before_filter :may_read_consents_required,
		:only => [:show,:index]
	before_filter :may_update_consents_required,
		:only => [:edit,:update]
#	before_filter :may_destroy_consents_required,
#		:only => :destroy

	before_filter :valid_study_subject_id_required,
		:only => [:show,:edit]
#		:only => [:new,:create,:index]

	def show
#		@enrollment = Enrollment.find(:first,
#			:conditions => { 
#				:study_subject_id => @study_subject.id,
#				:project_id => Project['ccls'].id 
#			}
#		)
		@enrollment = @study_subject.enrollments.find_or_create_by_project_id(
			Project['ccls'].id )
	end

	def edit
		@enrollment = @study_subject.enrollments.find_or_create_by_project_id(
			Project['ccls'].id )
	end

	def update
	end

end
