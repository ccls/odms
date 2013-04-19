class RemoveContextIdFromUnits < ActiveRecord::Migration
	def up
		remove_column :units, :context_id
	end

	def down
		add_column :units, :context_id, :integer
	end
end
