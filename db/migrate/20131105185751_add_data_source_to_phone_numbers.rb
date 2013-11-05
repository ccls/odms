class AddDataSourceToPhoneNumbers < ActiveRecord::Migration
	def change
		add_column :phone_numbers, :data_source, :string
	end
end
