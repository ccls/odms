class ChangeAbstractsCytogenT821FromStringToInt < ActiveRecord::Migration
	def up
		change_column :abstracts, :cytogen_t821, :integer, :limit => 2
	end

	def down
		change_column :abstracts, :cytogen_t821, :string, :limit => 9
	end
end
