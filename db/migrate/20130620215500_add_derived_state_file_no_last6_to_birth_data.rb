class AddDerivedStateFileNoLast6ToBirthData < ActiveRecord::Migration
	def change
#		add_column :birth_data, :derived_state_file_no_last6, :integer
		add_column :birth_data, :derived_state_file_no_last6, :string, :limit => 6
	end
end
