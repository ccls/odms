class AllowFollowUpTypeIdToBeNull < ActiveRecord::Migration
	def up
		change_column :follow_ups, :follow_up_type_id, :integer, :null => true
	end

	def down
		change_column :follow_ups, :follow_up_type_id, :integer, :null => false
	end
end
