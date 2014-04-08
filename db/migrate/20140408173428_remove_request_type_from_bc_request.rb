class RemoveRequestTypeFromBcRequest < ActiveRecord::Migration
	def change
		remove_column :bc_requests, :request_type
	end
end
