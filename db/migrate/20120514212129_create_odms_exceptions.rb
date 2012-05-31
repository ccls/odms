class CreateOdmsExceptions < ActiveRecord::Migration
	def change
		create_table :odms_exceptions do |t|
			t.integer :exceptable_id
			t.string :exceptable_type
			t.string :name
			t.string :description
#			t.datetime :occurred_at
			t.boolean :is_resolved, :default => false
			t.text :notes
			t.timestamps
		end
	end
end
