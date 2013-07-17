class ChangeAbstractVitalStatusIdToVitalStatusCode < ActiveRecord::Migration
	def change
		rename_column :abstracts, :vital_status_id, :vital_status_code
	end
end
