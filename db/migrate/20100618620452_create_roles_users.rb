class CreateRolesUsers < ActiveRecord::Migration
	def self.up
		table_name = 'roles_users'
		create_table table_name, :id => false do |t|
			t.references :role
			t.references :user
		end unless table_exists?(table_name)
		idxs = indexes(table_name).map(&:name)
		add_index( table_name, :role_id
			) unless idxs.include?("index_#{table_name}_on_role_id")
		add_index( table_name, :user_id
			) unless idxs.include?("index_#{table_name}_on_user_id")
	end

	def self.down
		drop_table :roles_users
	end
end
