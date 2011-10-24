class ConsentsController < ApplicationController

#	before_filter :may_create_consents_required,
#		:only => [:new,:create]
	before_filter :may_read_consents_required,
		:only => [:show,:index]
#	before_filter :may_update_consents_required,
#		:only => [:edit,:update]
#	before_filter :may_destroy_consents_required,
#		:only => :destroy

	before_filter :valid_study_subject_id_required,
		:only => [:index]
#		:only => [:new,:create,:index]

	def index
#		@events = OperationalEvent.search(params)
	end

end
