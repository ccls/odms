class PhoneNumbersController < ApplicationController

#	permissive
#
#	before_filter :valid_hx_subject_id_required,
#		:only => [:new,:create,:index]
#	before_filter :valid_id_required,
#		:only => [:edit,:update,:destroy]
#
#	def new
#		@phone_number = PhoneNumber.new
#	end
#
#	def create
#		@phone_number = @subject.phone_numbers.build(
#			params[:phone_number].merge( :current_user => current_user ) )
##		@phone_number = @subject.phone_numbers.build(params[:phone_number])
#		@phone_number.save!
#		redirect_to subject_contacts_path(@phone_number.subject)
#	rescue ActiveRecord::RecordNotSaved, ActiveRecord::RecordInvalid
#		flash.now[:error] = "PhoneNumber creation failed"
#		render :action => 'new'
#	end
#
##Editors can modify the current address and designated it as being an invalid address. If they designated the address as invalid, the why_invalid text field is mandatory.
##
##By default, there is no value for whether an address is valid.
##
##As part of subject tracing, we will have the ability to designated whether an address we have has been verified by some means. When an address is verified, the user will set is_verified to true. They will then be required to provide a value for the how_verified field and the system will capture both their user_id in verified_by and the current date in verified_on fields.
#
#	def update
#		@phone_number.update_attributes!(
#			params[:phone_number].merge( :current_user => current_user ) )
##		@phone_number.update_attributes!(params[:phone_number])
#		redirect_to subject_contacts_path(@phone_number.subject)
#	rescue ActiveRecord::RecordNotSaved, ActiveRecord::RecordInvalid
#		flash.now[:error] = "PhoneNumber update failed"
#		render :action => 'edit'
#	end
#
#
#
#	#	TEMP ADD FOR DEV ONLY!
#	def destroy
#		@phone_number.destroy
#		redirect_to subject_contacts_path(@phone_number.subject)
#	end
#
#
#protected
#
#	def valid_id_required
#		if !params[:id].blank? and PhoneNumber.exists?(params[:id])
#			@phone_number = PhoneNumber.find(params[:id])
#		else
#			access_denied("Valid phone_number id required!", 
#				subjects_path)
#		end
#	end

end
