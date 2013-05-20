class AllowSectionIdToBeNull < ActiveRecord::Migration
	def up
		change_column :follow_ups, :section_id, :integer, :null => true
	end

	def down
		change_column :follow_ups, :section_id, :integer, :null => false
	end
end
