class AddPhoneTypeToPhoneNumbers < ActiveRecord::Migration
	def change
		add_column :phone_numbers, :phone_type, :string
	end
end
