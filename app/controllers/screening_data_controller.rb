class ScreeningDataController < ApplicationController

	before_filter :may_create_screening_data_required,
		:only => [:new,:create,:parse]
	before_filter :may_read_screening_data_required,
		:only => [:show,:index]
	before_filter :may_update_screening_data_required,
		:only => [:edit,:update]
	before_filter :may_destroy_screening_data_required,
		:only => :destroy

	before_filter :valid_id_required, 
		:only => [:show,:edit,:update,:destroy,:parse]

end
