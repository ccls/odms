class AddUscCodeToCounties < ActiveRecord::Migration
	def change
		add_column :counties, :usc_code, :string, :limit => 2
	end
end
