class RemoveDataSourceIdFromAddress < ActiveRecord::Migration
	def up
		remove_column :addresses, :data_source_id
	end

	def down
		add_column :addresses, :data_source_id, :integer
	end
end
