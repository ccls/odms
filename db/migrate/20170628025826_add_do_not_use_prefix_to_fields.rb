class AddDoNotUsePrefixToFields < ActiveRecord::Migration
	def change
		rename_column :birth_data, :derived_local_file_no_last6,
			:do_not_use_derived_local_file_no_last6
		rename_column :birth_data, :derived_state_file_no_last6,
			:do_not_use_derived_state_file_no_last6
		rename_column :study_subjects, :local_registrar_no,
			:do_not_use_local_registrar_no
		rename_column :study_subjects, :state_id_no,
			:do_not_use_state_id_no
		rename_column :study_subjects, :state_registrar_no,
			:do_not_use_state_registrar_no
	end
end
