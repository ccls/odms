class DropDiagnoses < ActiveRecord::Migration
	def up
		drop_table :diagnoses
		remove_column :patients, :diagnosis_id
	end

	def down
		create_table :diagnoses do |t|
			t.integer  "position"
			t.string   "key",         :null => false
			t.string   "description", :null => false
			t.datetime "created_at",  :null => false
			t.datetime "updated_at",  :null => false
		end
	
		add_index "diagnoses", ["description"], :name => "index_diagnoses_on_description", :unique => true
		add_index "diagnoses", ["key"], :name => "index_diagnoses_on_key", :unique => true
		add_column :patients, :diagnosis_id, :integer
	end
end
