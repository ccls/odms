class ContactsController < ApplicationController

	permissive

#	before_filter :valid_hx_study_subject_id_required
	before_filter :valid_study_subject_id_required

end
