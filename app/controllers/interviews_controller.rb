class InterviewsController < ApplicationController

	before_filter :may_read_study_subjects_required, 
		:only => [:dashboard,:find,:followup,:reports,:index]

	before_filter :valid_study_subject_id_required,
		:only => [:index]

end
