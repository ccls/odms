class CreateSamples < ActiveRecord::Migration
	def self.up
		create_table :samples do |t|
			t.integer :parent_sample_id
			t.integer :sample_type_id
			t.integer :project_id
			t.integer :study_subject_id
			t.integer :unit_id
			t.integer :location_id
			t.integer :sample_collector_id

			t.integer :order_no
			t.decimal :quantity_in_sample, :precision => 8, :scale => 2
			t.string  :aliquot_or_sample_on_receipt
			t.datetime :sent_to_subject_at
			t.datetime :collected_from_subject_at
			t.datetime :shipped_to_ccls_at
			t.datetime :received_by_ccls_at
			t.datetime :sent_to_lab_at
			t.datetime :received_by_lab_at
			t.datetime :aliquotted_at
			t.string  :external_id
			t.string  :external_id_source
			t.datetime :receipt_confirmed_at
			t.string  :receipt_confirmed_by
			t.boolean :future_use_prohibited, :default => false, :null => false
			t.string  :state
			t.timestamps
			t.string  :sample_format
			t.string  :sample_temperature
			t.text    :notes
		end
		add_index :samples, :study_subject_id
	end

	def self.down
		drop_table :samples
	end
end
