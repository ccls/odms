class CreateRoles < ActiveRecord::Migration
	def self.up
		table_name = 'roles'
		create_table table_name do |t|
			t.integer :position
			t.string :name
			t.timestamps
		end unless table_exists?(table_name)
		idxs = indexes(table_name).map(&:name)
		add_index( table_name, :name, :unique => true
			) unless idxs.include?("index_#{table_name}_on_name")
	end

	def self.down
		drop_table :roles
	end
end
