class SamplesController < ApplicationController

	before_filter :may_read_study_subjects_required, 
		:only => [:dashboard,:find,:followup,:reports]

end
