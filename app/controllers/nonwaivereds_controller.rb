#class NonwaiveredsController < RafController
class NonwaiveredsController < ApplicationController
#
#	def new
#		@hospitals = Hospital.active.nonwaivered.includes(:organization)
#			.order('organizations.name ASC')
#		@study_subject = StudySubject.new(params[:study_subject])
#	end
#
##	@hospitals only actually needed if organization not passed to study_subject
##	would put this in view, but is common template with different values
#
#	def create
#		@hospitals = Hospital.active.nonwaivered.includes(:organization)
#			.order('organizations.name ASC')
#		study_subject_params = params[:study_subject].dup.to_hash
#
#		#	Paper form does not have consented checkbox, but our model
#		#		requires it so add it if ...
#		unless study_subject_params.dig("enrollments_attributes","0","consented_on").blank?
#			study_subject_params["enrollments_attributes"]["0"]["consented"] = YNDK[:yes]
#		end
#
#		#	The nonwaivered form does not contain raf_zip and raf_county
#		#	which is why they are copied in.
#		#	Copy address' county and zip into patient raf_county and raf_zip [#8]
#		# patient_attributes should never actually be blank except in testing.
#		study_subject_params["patient_attributes"]||={}
#		study_subject_params["patient_attributes"]["raf_zip"] = 
#			study_subject_params.dig("addressings_attributes","0",
#				"address_attributes","zip")
#
#		study_subject_params["patient_attributes"]["raf_county"] = 
#			study_subject_params.dig("addressings_attributes","0",
#				"address_attributes","county")
#
#		study_subject_params["addressings_attributes"]["0"][
#			"address_required"] = true
#
##	perhaps eventually? Custom validation is working.
##	We can't really have this in the model for all as much of the old
##	data does not have it.  What to do?
##		study_subject_params["language_required"] = true
#
#		common_raf_create(study_subject_params)
#	end
#
end
