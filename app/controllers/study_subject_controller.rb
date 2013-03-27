class StudySubjectController < ApplicationController

	layout 'subject'

	before_filter :valid_study_subject_id_required

end
