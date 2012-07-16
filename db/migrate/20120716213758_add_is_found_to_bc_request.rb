class AddIsFoundToBcRequest < ActiveRecord::Migration
	def change
		add_column :bc_requests, :is_found, :boolean
	end
end
