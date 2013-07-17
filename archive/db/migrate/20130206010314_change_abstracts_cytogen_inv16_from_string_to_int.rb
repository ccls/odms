class ChangeAbstractsCytogenInv16FromStringToInt < ActiveRecord::Migration
	def up
		change_column :abstracts, :cytogen_inv16, :integer, :limit => 2
	end

	def down
		change_column :abstracts, :cytogen_inv16, :string, :limit => 9
	end
end
