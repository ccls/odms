class AddExceptableAssociationToOdmsException < ActiveRecord::Migration
	def change
		add_column :odms_exceptions, :exceptable_id, :integer
		add_column :odms_exceptions, :exceptable_type, :string
	end
end
