class StudySubject::BirthRecordsController < StudySubjectController

	before_filter :may_read_birth_records_required

#	before_filter :may_create_patients_required,
#		:only => [:new,:create]
#	before_filter :may_read_patients_required,
#		:only => [:show,:index]
#	before_filter :may_update_patients_required,
#		:only => [:edit,:update]
#	before_filter :may_destroy_patients_required,
#		:only => :destroy

	def index
	end

end
