class StudySubject::InterviewsController < StudySubjectController

	before_filter :may_read_study_subjects_required

	def index
	end

end
