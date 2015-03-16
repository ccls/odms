class DropPeople < ActiveRecord::Migration
	def self.down
		create_table :people do |t|
			t.integer :position
			t.string  :first_name
			t.string  :last_name
			t.string  :honorific, :limit => 20
			t.integer :person_type_id
			t.integer :organization_id
			t.string  :email
			t.timestamps
		end
	end

	def self.up
		drop_table :people
	end
end
