class CreateSampleCollectors < ActiveRecord::Migration
	def change
		create_table :sample_collectors do |t|
			t.integer :organization_id
			t.string :other_organization
			t.timestamps
		end
		add_index :sample_collectors, :organization_id
	end
end
