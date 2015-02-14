class CreatePatients < ActiveRecord::Migration
	def self.up
		create_table :patients do |t|
			t.integer :study_subject_id
			t.date    :diagnosis_date
			t.integer :organization_id
			t.date    :admit_date
			t.date    :treatment_began_on
			t.integer :sample_was_collected
			t.string  :admitting_oncologist
			t.integer :was_ca_resident_at_diagnosis
			t.integer :was_previously_treated
			t.integer :was_under_15_at_dx
			t.string  :raf_zip, :limit => 10
			t.string  :raf_county
			t.string  :hospital_no, :limit => 25
			t.string  :other_diagnosis
			t.timestamps
			t.integer :is_study_area_resident
			t.string  :diagnosis
		end
		add_index :patients, :study_subject_id, :unique => true
		add_index :patients, :organization_id
		add_index :patients, [:hospital_no,:organization_id],
			:unique => true, :name => 'hosp_org'
	end

	def self.down
		drop_table :patients
	end
end
