class CreatePhoneNumbers < ActiveRecord::Migration
	def self.up
		create_table :phone_numbers do |t|
			t.integer  :position
			t.integer  :study_subject_id
			t.string   :phone_number
			t.boolean  :is_primary
			t.integer  :current_phone, :default => 1
			t.string   :other_data_source
			t.timestamps
			t.string   :phone_type
			t.string   :data_source
		end
		add_index :phone_numbers, :study_subject_id
	end

	def self.down
		drop_table :phone_numbers
	end
end
