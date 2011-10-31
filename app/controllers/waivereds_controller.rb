class WaiveredsController < ApplicationController

	before_filter :may_create_study_subjects_required

	def new
		@study_subject = StudySubject.new
	end

	def create
		StudySubject.transaction do
			#
			#	Add defaults that are not on the forms.
			#	This is ugly, but they are required, so either here or 
			#	hidden in the view.  If put in view, then need to be explicitly
			#	set in tests as well.
			#	deep_merge does not work correctly with a HashWithIndifferentAccess
			#	convert to hash, but MUST use string keys, not symbols as
			#		real requests do not send symbols
			#
			study_subject_params = params[:study_subject].dup.to_hash.deep_merge({
				'subject_type_id' => SubjectType['Case'].id,
				'identifier_attributes' => {
					'case_control_type' => 'C'
				},
				'enrollments_attributes' => {
					'0' => { "project_id"=> Project['phase5'].id }
				},
				'addressings_attributes' => {
					'0' => { "current_address"=>"1",
						'address_attributes' => { 
							'address_type_id' => AddressType['residence'].id
						} 
					}
				},
				'phone_numbers_attributes' => {
					'0' => { 'phone_type_id' => PhoneType['home'].id },
					'1' => { 'phone_type_id' => PhoneType['home'].id }
				}
			})

			@study_subject = StudySubject.new(study_subject_params)
			@study_subject.save!
			@study_subject.assign_icf_master_id
			@study_subject.create_mother

			warn = []
			if @study_subject.identifier.icf_master_id.blank?
				warn << "Control was not assigned an icf_master_id."
			end
			if @study_subject.mother.identifier.icf_master_id.blank?
				warn << "Mother was not assigned an icf_master_id."
			end
			flash[:warn] = warn.join('<br/>') unless warn.empty?
		end
		redirect_to @study_subject
	rescue ActiveRecord::RecordNotSaved, ActiveRecord::RecordInvalid
		flash.now[:error] = "StudySubject creation failed"
		render :action => 'new'
	rescue ActiveRecord::StatementInvalid => e
		flash.now[:error] = "Database error.  Check production logs and contact Jake."
		render :action => 'new'
	end

end
