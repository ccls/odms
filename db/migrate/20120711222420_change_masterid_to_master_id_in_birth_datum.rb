class ChangeMasteridToMasterIdInBirthDatum < ActiveRecord::Migration
	def up
		rename_column :birth_data, :masterid, :master_id
	end

	def down
		rename_column :birth_data, :master_id, :masterid
	end
end
