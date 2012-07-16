class AddReturnedOnToBcRequest < ActiveRecord::Migration
	def change
		add_column :bc_requests, :returned_on, :date
	end
end
