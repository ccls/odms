class ChangeAbstractsCytogenInv16FromStringToInt < ActiveRecord::Migration
	def up
		change_column :abstracts, :cytogen_inv16, :integer
	end

	def down
		change_column :abstracts, :cytogen_inv16, :string, :limit => 9
	end
end
