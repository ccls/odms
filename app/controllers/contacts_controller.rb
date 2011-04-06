class ContactsController < ApplicationController

	permissive

	before_filter :valid_hx_subject_id_required

end
