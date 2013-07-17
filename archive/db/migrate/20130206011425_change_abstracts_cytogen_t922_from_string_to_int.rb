class ChangeAbstractsCytogenT922FromStringToInt < ActiveRecord::Migration
	def up
		change_column :abstracts, :cytogen_t922, :integer, :limit => 2
	end

	def down
		change_column :abstracts, :cytogen_t922, :string, :limit => 50
	end
end
