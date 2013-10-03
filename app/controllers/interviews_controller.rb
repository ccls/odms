class InterviewsController < ApplicationController

	before_filter :may_read_study_subjects_required, 
		:only => [:dashboard,:index,:followup,:reports]

	before_filter :valid_study_subject_id_required,
		:except => [:dashboard,:index,:followup,:reports]

end
