class StudySubject::BirthRecordsController < StudySubjectController

	before_filter :may_read_birth_records_required

	def index
	end
	def show
	end

end
