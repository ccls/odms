class ChangeAbstractVitalStatusIdToVitalStatusCode < ActiveRecord::Migration
	def up
		rename_column :abstracts, :vital_status_id, :vital_status_code
	end

	def down
		rename_column :abstracts, :vital_status_code, :vital_status_id
	end
end
