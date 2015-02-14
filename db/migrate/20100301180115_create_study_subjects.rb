class CreateStudySubjects < ActiveRecord::Migration
	def self.up
		create_table :study_subjects do |t|
			t.integer :hispanicity
			t.date    :reference_date
			t.string  :sex
			t.boolean :do_not_contact, :default => false, :null => false
			t.integer :mother_yrs_educ
			t.integer :father_yrs_educ
			t.string  :birth_type
			t.integer :mother_hispanicity
			t.integer :father_hispanicity
			t.string  :birth_county
			t.string  :is_duplicate_of, :limit => 6
			t.integer :mother_hispanicity_mex
			t.integer :father_hispanicity_mex
			t.integer :mom_is_biomom
			t.integer :dad_is_biodad

			#	Formerly pii fields
			t.string  :first_name
			t.string  :middle_name
			t.string  :last_name
			t.date    :dob
			t.date    :died_on
			t.string  :mother_first_name
			t.string  :mother_middle_name
			t.string  :mother_maiden_name
			t.string  :mother_last_name
			t.string  :father_first_name
			t.string  :father_middle_name
			t.string  :father_last_name
			t.string  :email
			t.string  :guardian_first_name
			t.string  :guardian_middle_name
			t.string  :guardian_last_name
			t.string  :other_guardian_relationship
			t.integer :mother_race_code
			t.integer :father_race_code
			t.string  :maiden_name
			t.string  :generational_suffix, :limit => 10
			t.string  :father_generational_suffix, :limit => 10
			t.string  :birth_year, :limit => 4
			t.string  :birth_city
			t.string  :birth_state
			t.string  :birth_country
			t.string  :other_mother_race
			t.string  :other_father_race

			#	Formerly identifier
			t.integer :childid
			t.string  :patid, :limit => 4
			t.string  :case_control_type, :limit => 1
			t.integer :orderno
			t.string  :lab_no
			t.string  :related_childid
			t.string  :related_case_childid
			t.string  :ssn
			t.string  :subjectid, :limit => 6
			t.string  :matchingid, :limit => 6
			t.string  :familyid, :limit => 6
			t.string  :state_id_no
			t.string  :childidwho, :limit => 10
			t.string  :studyid, :limit => 14
			t.string  :newid, :limit => 6
			t.string  :gbid, :limit => 26
			t.string  :lab_no_wiemels, :limit => 25
			t.string  :idno_wiemels, :limit => 10
			t.string  :accession_no, :limit => 25
			t.string  :studyid_nohyphen, :limit => 12
			t.string  :studyid_intonly_nohyphen, :limit => 12
			t.string  :icf_master_id, :limit => 9
			t.string  :state_registrar_no
			t.string  :local_registrar_no
			t.boolean :is_matched

			t.integer :phase
			t.integer :hispanicity_mex
			t.integer :legacy_race_code
			t.boolean :legacy_race_code_imported, :default => false
			t.timestamps
			t.string  :legacy_other_race
			t.string  :vital_status, :limit => 20
			t.integer :addresses_count, :default => 0
			t.integer :abstracts_count, :default => 0
			t.string  :case_icf_master_id, :limit => 9
			t.string  :mother_icf_master_id, :limit => 9
			t.string  :subject_type, :limit => 20
			t.integer :samples_count, :default => 0
			t.integer :cdcid
			t.integer :operational_events_count, :default => 0
			t.integer :phone_numbers_count, :default => 0
			t.integer :birth_data_count, :default => 0
			t.integer :interviews_count, :default => 0
			t.boolean :needs_reindexed, :default => false
			t.integer :enrollments_count, :default => 0
			t.integer :replication_id
			t.string  :guardian_relationship
		end
		add_index :study_subjects, :ssn, :unique => true
		add_index :study_subjects, [:patid,:case_control_type,:orderno],
			:unique => true,:name => 'piccton'
		add_index :study_subjects, :subjectid, :unique => true
		add_index :study_subjects, :state_id_no, :unique => true
		add_index :study_subjects, :icf_master_id, :unique => true
		add_index :study_subjects, :state_registrar_no, :unique => true
		add_index :study_subjects, :local_registrar_no, :unique => true
		add_index :study_subjects, :childid, :unique => true
		add_index :study_subjects, :studyid, :unique => true
		add_index :study_subjects, :gbid, :unique => true
		add_index :study_subjects, :lab_no_wiemels, :unique => true
		add_index :study_subjects, :idno_wiemels, :unique => true
		add_index :study_subjects, :accession_no, :unique => true
		add_index :study_subjects, :studyid_nohyphen, :unique => true
		add_index :study_subjects, :studyid_intonly_nohyphen, :unique => true
		add_index :study_subjects, :email, :unique => true
		add_index :study_subjects, :vital_status
		add_index :study_subjects, :subject_type
		add_index :study_subjects, [:phase, :case_icf_master_id]
		add_index :study_subjects, [:phase, :mother_icf_master_id]
		add_index :study_subjects, :needs_reindexed
		add_index :study_subjects, :matchingid
		add_index :study_subjects, :familyid
		add_index :study_subjects, :replication_id
	end

	def self.down
		drop_table :study_subjects
	end
end
