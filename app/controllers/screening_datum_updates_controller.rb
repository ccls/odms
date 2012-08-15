class ScreeningDatumUpdatesController < ApplicationController

	before_filter :may_create_screening_datum_updates_required,
		:only => [:new,:create,:parse]
	before_filter :may_read_screening_datum_updates_required,
		:only => [:show,:index]
	before_filter :may_update_screening_datum_updates_required,
		:only => [:edit,:update]
	before_filter :may_destroy_screening_datum_updates_required,
		:only => :destroy

	before_filter :valid_id_required, 
		:only => [:show,:edit,:update,:destroy,:parse]


end
