class AddAddressTypeToAddresses < ActiveRecord::Migration
	def change
		add_column :addresses, :address_type, :string
	end
end
