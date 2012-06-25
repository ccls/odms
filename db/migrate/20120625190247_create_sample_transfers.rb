class CreateSampleTransfers < ActiveRecord::Migration
	def change
		create_table :sample_transfers do |t|
			t.integer :sample_id
			t.integer :source_org_id
			t.integer :destination_org_id
			t.date :sent_on
			t.string :status
			t.text :notes
			t.timestamps
		end
	end
end
