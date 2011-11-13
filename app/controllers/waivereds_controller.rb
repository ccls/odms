class WaiveredsController < ApplicationController

	before_filter :may_create_study_subjects_required

	def new
		@hospitals = Hospital.waivered(:include => :organization)
		@study_subject = StudySubject.new(params[:study_subject])
	end

	def create
		@hospitals = Hospital.waivered(:include => :organization)
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
			'identifier_attributes' => { 'case_control_type' => 'C' },
			'enrollments_attributes' => { '0' => { "project_id"=> Project['ccls'].id } },
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
		common_raf_create(study_subject_params)
	end

end
