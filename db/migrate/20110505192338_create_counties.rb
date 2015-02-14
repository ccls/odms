class CreateCounties < ActiveRecord::Migration
	def change
		create_table :counties do |t|
			t.string :name
			t.string :fips_code, :limit => 5
			t.string :state_abbrev, :limit => 2
			t.string :usc_code, :limit => 2
			t.timestamps
		end
		add_index :counties, :state_abbrev
	end
end
