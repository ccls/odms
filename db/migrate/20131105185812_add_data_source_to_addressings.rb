class AddDataSourceToAddressings < ActiveRecord::Migration
	def change
		add_column :addressings, :data_source, :string
	end
end
