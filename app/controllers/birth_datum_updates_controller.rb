#	require 'csv'
class BirthDatumUpdatesController < ApplicationController
#
#	before_filter :may_create_birth_datum_updates_required,
#		:only => [:new,:create,:parse]
#	before_filter :may_read_birth_datum_updates_required,
#		:only => [:show,:index]
#	before_filter :may_update_birth_datum_updates_required,
#		:only => [:edit,:update]
#	before_filter :may_destroy_birth_datum_updates_required,
#		:only => :destroy
#
#	before_filter :valid_id_required, 
#		:only => [:show,:edit,:update,:destroy,:parse]
#
#
#	def index
#		@birth_datum_updates = BirthDatumUpdate.scoped
#	end
#
#	def show
#	end
#
#	def new
#		@birth_datum_update = BirthDatumUpdate.new
#	end
#
#	def create
#		@birth_datum_update = BirthDatumUpdate.new(params[:birth_datum_update])
#		@birth_datum_update.save!
#		flash[:notice] = 'Success!'
#		redirect_to @birth_datum_update
#	rescue ActiveRecord::RecordNotSaved, ActiveRecord::RecordInvalid
#		flash.now[:error] = "There was a problem creating the birth_datum_update"
#		render :action => "new"
#	rescue CSV::MalformedCSVError => e
#		flash.now[:error] = "CSV error.<br/>#{e}".html_safe
#		render :action => 'new'
#	end
#
##	Edit/Update pointless as parsing is now automatic and AFTER CREATE
#
##	def edit
##	end
##
##	def update
##		@birth_datum_update.update_attributes!(params[:birth_datum_update])
##		flash[:notice] = 'Success!'
##		redirect_to birth_datum_updates_path
##	rescue ActiveRecord::RecordNotSaved, ActiveRecord::RecordInvalid
##		flash.now[:error] = "There was a problem updating the birth_datum_update"
##		render :action => "edit"
##	end
#
#	def destroy
#		@birth_datum_update.destroy
#		redirect_to(birth_datum_updates_path)
#	end
#
##	def parse
##		if !@birth_datum_update.csv_file_file_name.blank? &&
##				File.exists?(@birth_datum_update.csv_file.path)
##			@results = @birth_datum_update.to_candidate_controls
##			f=CSV.open(@birth_datum_update.csv_file.path,'rb',{:headers => true })
##			@csv_lines = f.readlines
##			f.close
##		else
##			flash[:error] = "Birth Datum csv file not found."
##			redirect_to @birth_datum_update
##		end
##	end
#
#protected
#
#	def valid_id_required
#		if( !params[:id].blank? && BirthDatumUpdate.exists?(params[:id]) )
#			@birth_datum_update = BirthDatumUpdate.find(params[:id])
#		else
#			access_denied("Valid id required!", birth_datum_updates_path)
#		end
#	end
#
end
